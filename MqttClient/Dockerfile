# Sử dụng base image Python bản slim siêu nhẹ
FROM python:3.11-slim

# Ngăn Python ghi file .pyc ra đĩa cứng và ép log xuất thẳng ra console
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Cài đặt thư mục làm việc bên trong container
WORKDIR /app

# Copy file requirements vào trước để tận dụng cơ chế Cache của Docker
COPY requirements.txt .

# Cài đặt các thư viện không lưu cache để giảm dung lượng image
RUN pip install --no-cache-dir -r requirements.txt

# Copy toàn bộ mã nguồn và thư mục certs vào container
COPY . .

# Mở cổng 8000 (Cổng mặc định của FastAPI)
EXPOSE 8000

# Lệnh chạy server khi container khởi động
CMD ["python", "main.py"]