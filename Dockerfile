# ==================== GIAI ĐOẠN 1: BUILD ỨNG DỤNG ====================
# Sử dụng image Maven với JDK 17 làm môi trường build.
# Đây là image nặng, chỉ dùng để biên dịch code.
FROM maven:3.8.5-openjdk-17 AS build

# Đặt thư mục làm việc bên trong container.
WORKDIR /app

# Copy file cấu hình Maven (pom.xml) trước để Docker tận dụng cache.
COPY pom.xml .

# Tải về tất cả các dependencies.
RUN mvn dependency:go-offline

# Copy toàn bộ mã nguồn của ứng dụng.
COPY src ./src

# Biên dịch ứng dụng và đóng gói thành file JAR.
# -DskipTests: bỏ qua chạy các bài kiểm tra để tăng tốc độ build.
RUN mvn clean package -DskipTests

# ==================== GIAI ĐOẠN 2: CHẠY ỨNG DỤNG ====================
# Sử dụng một image JRE nhẹ hơn (OpenJDK 17 Slim) cho môi trường runtime.
FROM openjdk:17-slim

# Đặt thư mục làm việc cho ứng dụng đã build.
WORKDIR /app

# Copy file JAR đã được build từ giai đoạn 'build' vào giai đoạn runtime.
# Tên file JAR thường là tên project của bạn.
# Để đơn giản, bạn có thể cấu hình Maven để tạo file tên là 'app.jar'.
# (Xem phần 2.3 dưới đây nếu bạn chưa làm)
COPY --from=build /app/target/*.jar app.jar

# Khai báo cổng mà ứng dụng sẽ lắng nghe (mặc định 8080).
EXPOSE 8080

# Lệnh sẽ được thực thi khi container khởi động.
ENTRYPOINT ["java", "-jar", "app.jar"]