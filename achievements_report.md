# KẾT QUẢ ĐẠT ĐƯỢC VÀ THỐNG KÊ MÃ NGUỒN - FLOODHELPER
*(Achievements and Source Code Statistics)*

Tài liệu này chứa nội dung chi tiết về kết quả đạt được (sản phẩm đóng gói, thành phần, vai trò) và bảng thống kê mã nguồn của dự án **FloodHelper** (tên gọi khác: **antiflood**).

Nội dung dưới đây được thiết kế thành **2 phần**:
1. **Bản tiếng Việt**: Để bạn dễ dàng đọc hiểu, đối chiếu và chuẩn bị nội dung báo cáo tốt nghiệp.
2. **Mã nguồn LaTeX (Bản tiếng Anh)**: Được định dạng chuẩn LaTeX để bạn sao chép và dán trực tiếp vào file báo cáo tốt nghiệp `4_Experiment_evaluation.tex` của mình (mục `\subsection{Achievement}`).

---

## PHẦN 1: BẢN TIẾNG VIỆT (GIẢI THÍCH & THỐNG KÊ CHI TIẾT)

### 1. Các sản phẩm đóng gói (Packaged Products)
Hệ thống **FloodHelper** sau khi phát triển hoàn thiện được đóng gói thành các sản phẩm phần mềm độc lập để phục vụ triển khai và sử dụng thực tế:

*   **Sản phẩm 1: Ứng dụng Khách - Mobile App (Android APK) & Web Build**
    *   **Tên file đóng gói:** `app-debug.apk` (hoặc `app-release.apk` khi build production) và thư mục web bundle.
    *   **Thành phần chính:** Dart/Flutter framework libraries, các thành phần giao diện (UI screens, Distress signal panels, SOS sheet, Map pin components, Charity allocations), hệ thống quản lý trạng thái (Riverpod), các dịch vụ tích hợp bên thứ ba (Dio HTTP client, Geolocator GPS, MqttClient, Firebase Messaging SDK).
    *   **Ý nghĩa và vai trò:** Giao diện tương tác trực tiếp của người dùng. Mobile App hỗ trợ nạn nhân gửi SOS kèm định vị GPS, cập nhật vị trí thời gian thực và giúp lực lượng cứu hộ định vị tìm kiếm nạn nhân trên bản đồ số. Web App hỗ trợ cơ quan chức năng giám sát hoạt động cứu trợ, quản lý và duyệt các chiến dịch từ thiện.

*   **Sản phẩm 2: Máy chủ Dịch vụ - Backend API Application Server**
    *   **Tên file đóng gói:** Docker Image (`floodhelper-backend:latest`) chứa mã nguồn NestJS đã được build sang JavaScript (`dist/` folder).
    *   **Thành phần chính:** Node.js runtime, NestJS framework, Prisma ORM clients, Controller endpoints (xử lý routing HTTP), Service components (xử lý logic nghiệp vụ cứu nạn, từ thiện), Repository classes (truy vấn database).
    *   **Ý nghĩa và vai trò:** Trực tiếp quản lý và xử lý dữ liệu trung tâm của toàn bộ hệ thống. Đảm nhận việc xác thực tài khoản, kiểm tra bảo mật dữ liệu, tích hợp các gateway dịch vụ khác như VietQR (thanh toán/quyên góp tự động), Firebase Admin SDK (gửi push notification) và Cloudinary (lưu trữ ảnh cứu trợ).

*   **Sản phẩm 3: Bộ điều phối dữ liệu thời gian thực - MQTT Worker Client**
    *   **Tên file đóng gói:** Docker Image (`floodhelper-mqtt-worker:latest`) chạy trên nền tảng Python/FastAPI.
    *   **Thành phần chính:** Python runtime, FastAPI server instance, Paho-MQTT connection manager, HTTP dispatcher client gửi dữ liệu đến server chính.
    *   **Ý nghĩa và vai trò:** Hoạt động độc lập và song song với Backend API Server. Vai trò chính là điều phối và đồng bộ dữ liệu tọa độ thời gian thực. Phân hệ này "Subscribe" các luồng tọa độ GPS gửi lên liên tục tần suất cao từ thiết bị người dùng qua giao thức MQTT. Khi cần đồng bộ dữ liệu, nó không ghi trực tiếp vào cơ sở dữ liệu mà chuyển tiếp gói tin (forward) qua các REST API endpoint của Server chính (NestJS Backend) để xử lý nghiệp vụ và lưu trữ. Cơ chế này giúp giảm tải các kết nối MQTT tần số cao cho máy chủ chính, đồng thời giữ nguyên vẹn thiết kế kiến trúc phân lớp.

*   **Sản phẩm 4: Hệ cơ sở dữ liệu quan hệ (Relational Database Schema)**
    *   **Tên sản phẩm:** Cấu trúc Schema cơ sở dữ liệu (`schema.prisma` triển khai trên PostgreSQL).
    *   **Thành phần chính:** Gồm 16 bảng dữ liệu (User, Account, Profile, Session, Signal, Friendship, CharityCampaign, Transaction, Supply, FinancialSupport, Bank, ChatRoom, Message, Province, Ward, WeatherMap) có liên kết chặt chẽ.
    *   **Ý nghĩa và vai trò:** Lưu trữ toàn bộ dữ liệu mang tính bền vững của dự án, tối ưu hóa các câu lệnh truy vấn liên kết vị trí địa lý, lịch sử giao dịch từ thiện và duy trì ràng buộc khóa ngoại chính xác.

---

### 2. Bảng thống kê mã nguồn (Codebase Statistics Table)

Bảng dưới đây thống kê chính xác số lượng file nguồn, số gói (thư mục), số lớp (classes), số dòng code thực tế và dung lượng mã nguồn của từng module (đã loại bỏ các thư mục như `node_modules`, `build`, `.git`, `.dart_tool`, v.v.):

| Phân hệ (Module) | Ngôn ngữ chính | Số lượng File | Số lượng Gói (Folders) | Số lượng Lớp (Classes) | Số dòng code (SLOC)* | Dung lượng mã nguồn | Sản phẩm đóng gói & Dung lượng |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **Frontend Mobile & Web** | Dart / Flutter | 279 | 81 | 409 | 41.667 *(36.311 thực tế)* | 1,26 MB | `app-debug.apk` (106,49 MB) / Release APK (~22 MB) |
| **Backend API Server** | TypeScript / NestJS | 145 | 36 | 123 | 13.299 *(11.106 thực tế)* | 358,86 KB | Docker Image (~320 MB) / Thư mục `dist` (1,60 MB) |
| **MQTT Client (Coordinator)** | Python / FastAPI | 6 | 2 | 3 | 455 *(364 thực tế)* | 15,39 KB | Docker Image (~120 MB) / Mã nguồn (15,39 KB) |
| **Tổng cộng hệ thống** | **Dart, TS, Python** | **430** | **119** | **535** | **55.421 *(47.781 thực tế)*** | **~1,63 MB** | **Trọn bộ sản phẩm phần mềm** |

*\*Ghi chú: Số dòng code hiển thị tổng số dòng bao gồm dòng trống và chú thích. Phần trong ngoặc là số dòng code thực tế chạy (Source Lines of Code).*

---

## PHẦN 2: MÃ NGUỒN LA-TEX (BẢN TIẾNG ANH CHO LUẬN VĂN)

Bạn chỉ cần copy toàn bộ đoạn mã LaTeX dưới đây và thay thế phần hướng dẫn nằm ở mục `\subsection{Achievement}` trong file `report/Graduation_Thesis/Chapter/4_Experiment_evaluation.tex`.

```latex
\subsection{Achievement}

The primary achievement of the FloodHelper project is the successful design, implementation, and packaging of a comprehensive, multi-platform software ecosystem designed to facilitate disaster response and charity coordinate activities. The system has been fully built, packaged, and verified through local deployments, comprising three distinct packaged products operating concurrently on a unified relational database.

\subsubsection{Packaged Software Products and Component Details}

This section describes the delivery package formats, key components, and architectural roles of each product within the FloodHelper ecosystem. For clarity, these details are summarized in Table \ref{table:packaged_products_details}.

\renewcommand{\arraystretch}{1.4}
\begin{xltabular}{\textwidth}{|P{2.8cm}|P{3.2cm}|X|X|}
    \caption{Details of Packaged Software Products}
    \label{table:packaged_products_details} \\
    \hline
    \textbf{Product / Module} & \textbf{Delivery Package} & \textbf{Key Components} & \textbf{Significance and Role} \\
    \hline
    \endfirsthead

    \multicolumn{4}{c}{{\tablename\ \thetable\ -- Continued from previous page}} \\
    \hline
    \textbf{Product / Module} & \textbf{Delivery Package} & \textbf{Key Components} & \textbf{Significance and Role} \\
    \hline
    \endhead

    \hline
    \multicolumn{4}{r}{\textit{Continued on next page}} \\
    \endfoot

    \hline
    \endlastfoot

    \textbf{Frontend Client} (Mobile App \& Web Admin Desk) & 
    Compiled Android APK (\texttt{app-debug.apk}: 106.49 MB, \texttt{app-release.apk}: $\approx$ 22 MB) and compiled static HTML/JS assets. & 
    Flutter layout widgets (\texttt{HomeScreen} map dashboard, \texttt{DistressSignalSheet}, \texttt{Charity} transaction cards, authority views), state providers (\texttt{Riverpod}), and client communication integrations (\texttt{Dio}, \texttt{Geolocator}, \texttt{MqttClient}). & 
    Serves as the interactive touchpoint. The mobile app lets users stream real-time coordinate changes via MQTT and dispatch SOS signals. The web app acts as the dispatch dashboard for rescue organizations to coordinate operations and approve charity requests. \\
    \hline
    \textbf{Backend Server} (NestJS API App) & 
    Self-contained Docker Image (\texttt{floodhelper-backend:latest} $\approx$ 320 MB) containing NestJS compiled JavaScript in \texttt{dist/} folder (1.60 MB, 430 files). & 
    REST Controllers mapping API routes, NestJS services for SOS validation and auth filters, Prisma database clients, and third-party integrations (Firebase Admin SDK, VietQR integration, Cloudinary API). & 
    Acts as the central business engine of the system, verifying accounts, securing data access boundaries, checking DTO inputs, managing notification triggers, and handling transactional email dispatches. \\
    \hline
    \textbf{MQTT Worker} (Data Coordinator) & 
    Lightweight Docker Image (\texttt{floodhelper-mqtt-worker:latest} $\approx$ 120 MB) running Python 3 and FastAPI. & 
    Persistent Paho-MQTT connection client, temporary background message queue handlers, and API request forwarding dispatcher. & 
    Acts as a real-time data coordinator. It subscribes to high-frequency MQTT coordinate streams from active devices. Instead of writing directly to the database, it processes and forwards coordinate payloads to main NestJS server REST endpoints to offload HTTP connection traffic and preserve architecture layers. \\
    \hline
    \textbf{Database Schema} (PostgreSQL) & 
    Database initialization scripts and migration files generated via \texttt{prisma/schema.prisma}. & 
    Structured tables (\texttt{User}, \texttt{Account}, \texttt{Profile}, \texttt{Signal}, \texttt{Friendship}, \texttt{CharityCampaign}, \texttt{Transaction}, geocoded tables for \texttt{Province} and \texttt{Ward}). & 
    Provides persistent storage with transactional integrity, enforcing one-to-one mapping for accounts, one-to-many associations for tracking history, and multi-relational structures for volunteer messaging and spatial tracking. \\
    \hline
\end{xltabular}

\subsubsection{Source Code and Package Metrics}

To evaluate the engineering scope of the system, a static code analysis was conducted across all active repositories. Excluded from this assessment are third-party libraries (\texttt{node\_modules}, generated Flutter assets in \texttt{.dart\_tool}, test cache files, and report documents). Table \ref{table:code_statistics} details the breakdown of source files, package modules, class counts, source lines of code (SLOC), and physical sizes.

\begin{table}[H]
    \centering
    \caption{Summary of Source Code and Packaged Product Statistics}
    \label{table:code_statistics}
    \renewcommand{\arraystretch}{1.3} % Tighten row margins for legibility
    \begin{tabularx}{\textwidth}{|X|c|c|c|c|c|X|}
        \hline
        \textbf{Module / Product} & \textbf{Language} & \textbf{Files} & \textbf{Packages} & \textbf{Classes} & \textbf{Lines of Code*} & \textbf{Packaged Product \& Size} \\
        \hline
        \textbf{Frontend Client} (Mobile \& Web) & Dart & 279 & 81 & 409 & 41,667 (36,311 code) & \texttt{app-debug.apk} (106.49 MB) / Release APK ($\approx$ 22 MB) \\
        \hline
        \textbf{Backend Server} (API Application) & TypeScript & 145 & 36 & 123 & 13,299 (11,106 code) & Docker Container ($\approx$ 320 MB) / Dist folder (1.60 MB) \\
        \hline
        \textbf{MQTT Client} (Coordinator) & Python & 6 & 2 & 3 & 455 (364 code) & Docker Container ($\approx$ 120 MB) / Source code (15.39 KB) \\
        \hline
        \textbf{Total System} & \textbf{Dart/TS/Py} & \textbf{430} & \textbf{119} & \textbf{535} & \textbf{55,421 (47,781)} & \textbf{Full software suite} \\
        \hline
    \end{tabularx}
    \vspace{0.1cm}
    \caption*{\textit{*Note: Lines of code are shown as Total Lines (Source Lines of Code excluding blanks and comments in parentheses).}}
\end{table}
```
