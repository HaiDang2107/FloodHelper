import json
import os
import ssl
from contextlib import asynccontextmanager
from fastapi import FastAPI
import paho.mqtt.client as mqtt
from dotenv import load_dotenv # Thêm dòng này

# Ép Python đọc file .env ở cùng thư mục và đưa vào hệ thống
load_dotenv()

# --- THÔNG SỐ CẤU HÌNH EMQX CLOUD ---
MQTT_BROKER = os.getenv("MQTT_BROKER")
MQTT_PORT = int(os.getenv("MQTT_PORT", 8883))
# Đường dẫn tương đối từ file main.py tới file cert
CA_CERT_RELATIVE_PATH = "certs/emqxsl-ca.crt" 

# Nếu test nhanh, bạn có thể điền trực tiếp chuỗi vào đây.
MQTT_USERNAME = os.getenv("MQTT_USERNAME", "YOUR_MQTT_USERNAME")
MQTT_PASSWORD = os.getenv("MQTT_PASSWORD", "YOUR_MQTT_PASSWORD")

# Topic lắng nghe chính
TOPIC_INPUT = "current-location"

# Khởi tạo MQTT Client global
mqtt_client = mqtt.Client(
    mqtt.CallbackAPIVersion.VERSION1, 
    client_id="FastAPI_Location_Worker", 
    clean_session=True
)

# --- CÁC HÀM XỬ LÝ SỰ KIỆN MQTT (CALLBACKS) ---

def on_connect(client, userdata, flags, rc):
    """Callback khi kết nối thành công tới Broker."""
    if rc == 0:
        print(f"✅ MQTT Client đã kết nối bảo mật tới Broker tại cổng {MQTT_PORT}")
        # Subscribe vào topic chính
        client.subscribe(TOPIC_INPUT, qos=0)
        print(f"🎧 Đang lắng nghe trên topic: {TOPIC_INPUT}")
    else:
        print(f"❌ Kết nối thất bại, mã lỗi (rc): {rc}")

def on_message(client, userdata, msg):
    """Callback khi nhận được tin nhắn mới."""
    try:
        # 1. Đọc và Parse dữ liệu JSON đến
        payload_raw = msg.payload.decode('utf-8')
        print(f"\n📩 Nhận data mới từ {msg.topic}")
        data = json.loads(payload_raw)

        # 2. Trích xuất thông tin cần thiết
        # Sử dụng .get() để tránh lỗi nếu thiếu trường dữ liệu
        lat = data.get("lat")
        lng = data.get("lng")
        sender_user = data.get("user")
        allowed_friends = data.get("allowed_friends", [])

        # Kiểm tra dữ liệu bắt buộc
        if not all([lat, lng, sender_user]) or not allowed_friends:
            print("⚠️ Data không hợp lệ (thiếu lat, lng, user, hoặc allowed_friends). Bỏ qua.")
            return

        # 3. Chuẩn bị Payload mới (chỉ gồm lat và lng)
        new_payload = {
            "lat": lat,
            "lng": lng
        }
        new_payload_json = json.dumps(new_payload)

        # 4. XỬ LÝ REPUBLISH CHO TỪNG NGƯỜI BẠN (FAN-OUT)
        for friend_id in allowed_friends:
            # Xây dựng topic đích: user/to_<friend_id>/last-location
            target_topic = f"{sender_user}/to_{friend_id}/last-location"
            
            # --- ĐÂY LÀ KHÚC QUAN TRỌNG NHẤT ĐỂ SỬA LỖI EMQX CLOUD ---
            # Gọi hàm publish với retain=True. 
            # Broker sẽ lưu lại vị trí này làm 'Retained Message'.
            result = client.publish(
                target_topic, 
                payload=new_payload_json, 
                qos=0, 
                retain=True # <--- BẮT BUỘC PHẢI CÓ
            )
            
            # Kiểm tra trạng thái gửi (tùy chọn, để debug)
            if result.rc == mqtt.MQTT_ERR_SUCCESS:
                print(f"🚀 -> {target_topic} (Retain: True)")
            else:
                print(f"❌ Gửi thất bại tới {target_topic}")

    except json.JSONDecodeError:
        print("⚠️ Payload nhận được không phải là JSON hợp lệ.")
    except Exception as e:
        print(f"⚠️ Lỗi xử lý tin nhắn: {e}")

# --- CẤU HÌNH LIFESPAN CHO FASTAPI ---
# Giúp quản lý vòng đời của MQTT Client song song với API Server

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Xử lý sự kiện startup và shutdown của FastAPI."""
    
    # 1. Khởi chạy khi API Server bắt đầu (Startup)
    print("\nStarting FastAPI MQTT Worker...")
    
    # Gắn các hàm callback
    mqtt_client.on_connect = on_connect
    mqtt_client.on_message = on_message
    mqtt_client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)

    # Cấu hình đường dẫn tuyệt đối cho file CA Cert để đảm bảo không lỗi
    base_path = os.path.dirname(os.path.abspath(__file__))
    ca_cert_absolute_path = os.path.join(base_path, CA_CERT_RELATIVE_PATH)

    # Cấu hình bảo mật TLS/SSL (Cổng 8883)
    try:
        mqtt_client.tls_set(
            ca_certs=ca_cert_absolute_path, 
            tls_version=ssl.PROTOCOL_TLSv1_2
        )
    except FileNotFoundError:
        print(f"❌ LỖI KHÔNG TÌM THẤY FILE CA CERT tại: {ca_cert_absolute_path}")
        print("Hệ thống sẽ dừng lại để đảm bảo bảo mật.")
        os._exit(1) # Dừng toàn bộ chương trình nếu thiếu file mật thiết

    # Kết nối không chặn (non-blocking) tới Broker
    mqtt_client.connect_async(MQTT_BROKER, MQTT_PORT, keepalive=60)
    
    # Bắt đầu vòng lặp xử lý mạng MQTT trong một luồng riêng
    mqtt_client.loop_start()
    
    yield
    
    # 2. Khởi chạy khi API Server tắt (Shutdown)
    print("\nStopping FastAPI MQTT Worker...")
    mqtt_client.loop_stop()
    mqtt_client.disconnect()
    print("Mqtt Client disconnected.")

# --- KHỞI TẠO FASTAPI APP ---
app = FastAPI(lifespan=lifespan)

# Một API endpoint đơn giản để kiểm tra tình trạng server
@app.get("/")
async def health_check():
    mqtt_status = "Connected" if mqtt_client.is_connected() else "Disconnected"
    return {
        "status": "API Server runs", 
        "mqtt_worker": mqtt_status
    }

# --- ĐỂ CHẠY SERVER ---
# uvicorn main:app --reload
# Dùng lệnh: uvicorn main:app --reload
# (Giả sử bạn lưu file này là main.py)