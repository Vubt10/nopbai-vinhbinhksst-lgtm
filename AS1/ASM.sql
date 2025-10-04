
CREATE DATABASE QLNHATRO_hytruong; 
GO

USE QLNHATRO_hytruong;
GO

-- Bảng LOAINHA
CREATE TABLE LOAINHA (
    MALOAINHA INT IDENTITY PRIMARY KEY,
    TENLOAI NVARCHAR(100) NOT NULL
);

-- Bảng NGUOIDUNG
CREATE TABLE NGUOIDUNG (
    MAND INT IDENTITY PRIMARY KEY,
    TENND NVARCHAR(100) NOT NULL,
    GIOITINH NVARCHAR(10) CHECK (GIOITINH IN (N'Nam', N'Nữ')),
    DIENTHOAI VARCHAR(15) NOT NULL,
    DIACHI NVARCHAR(200) NOT NULL,
    QUAN NVARCHAR(50) NOT NULL,
    EMAIL VARCHAR(100) UNIQUE NOT NULL
);

-- Bảng NHATRO
CREATE TABLE NHATRO (
    MANT INT IDENTITY PRIMARY KEY,
    MALOAINHA INT NOT NULL FOREIGN KEY REFERENCES LOAINHA(MALOAINHA),
    DIENTICH DECIMAL(10,2) NOT NULL CHECK (DIENTICH > 0),
    GIAPHONG DECIMAL(18,0) NOT NULL CHECK (GIAPHONG > 0),
    DIACHI NVARCHAR(200) NOT NULL,
    QUAN NVARCHAR(50) NOT NULL,
    MOTA NVARCHAR(500),
    NGAYDANG DATE DEFAULT GETDATE(),
    NGUOILIENHE INT NOT NULL FOREIGN KEY REFERENCES NGUOIDUNG(MAND)
);

-- Bảng DANHGIA
CREATE TABLE DANHGIA (
    MADG INT IDENTITY PRIMARY KEY,
    MAND INT NOT NULL FOREIGN KEY REFERENCES NGUOIDUNG(MAND),
    MANT INT NOT NULL FOREIGN KEY REFERENCES NHATRO(MANT),
    TRANGTHAI NVARCHAR(10) CHECK (TRANGTHAI IN ('LIKE','DISLIKE')),
    NOIDUNG NVARCHAR(500)
);

/* =============================
   Y2. DỮ LIỆU MẪU
   ============================= */
-- LOAINHA
INSERT INTO LOAINHA (TENLOAI) VALUES
(N'Căn hộ chung cư'),
(N'Nhà riêng'),
(N'Phòng trọ khép kín');

-- NGUOIDUNG (10 bản ghi)
INSERT INTO NGUOIDUNG (TENND, GIOITINH, DIENTHOAI, DIACHI, QUAN, EMAIL) VALUES
(N'Nguyễn Văn A', N'Nam', '0912345678', N'12 Ngõ 1, Trần Phú', N'Hà Đông', 'a@gmail.com'),
(N'Trần Thị B', N'Nữ', '0912345679', N'23 Ngõ 5, Giải Phóng', N'Hoàng Mai', 'b@gmail.com'),
(N'Lê Văn C', N'Nam', '0912345680', N'56 Phố Huế', N'Hai Bà Trưng', 'c@gmail.com'),
(N'Phạm Thị D', N'Nữ', '0912345681', N'78 Nguyễn Trãi', N'Thanh Xuân', 'd@gmail.com'),
(N'Hồ Văn E', N'Nam', '0912345682', N'90 Láng Hạ', N'Đống Đa', 'e@gmail.com'),
(N'Nguyễn Thị F', N'Nữ', '0912345683', N'11 Hoàng Hoa Thám', N'Ba Đình', 'f@gmail.com'),
(N'Trịnh Văn G', N'Nam', '0912345684', N'33 Lạc Long Quân', N'Tây Hồ', 'g@gmail.com'),
(N'Đỗ Thị H', N'Nữ', '0912345685', N'44 Xuân Thủy', N'Cầu Giấy', 'h@gmail.com'),
(N'Bùi Văn I', N'Nam', '0912345686', N'66 Tôn Đức Thắng', N'Đống Đa', 'i@gmail.com'),
(N'Phan Thị K', N'Nữ', '0912345687', N'88 Kim Ngưu', N'Hai Bà Trưng', 'k@gmail.com');

-- NHATRO (10 bản ghi)
INSERT INTO NHATRO (MALOAINHA, DIENTICH, GIAPHONG, DIACHI, QUAN, MOTA, NGUOILIENHE) VALUES
(1, 25.5, 1500000, N'12 Ngõ 1, Trần Phú', N'Hà Đông', N'Phòng sạch sẽ, có điều hòa', 1),
(2, 45.0, 3000000, N'23 Ngõ 5, Giải Phóng', N'Hoàng Mai', N'Nhà riêng, 2 tầng, đầy đủ tiện nghi', 2),
(3, 18.0, 1200000, N'56 Phố Huế', N'Hai Bà Trưng', N'Phòng khép kín, có gác xép', 3),
(1, 30.0, 2000000, N'78 Nguyễn Trãi', N'Thanh Xuân', N'Phòng thoáng mát, an ninh tốt', 4),
(2, 50.0, 3500000, N'90 Láng Hạ', N'Đống Đa', N'Nhà riêng, gần chợ', 5),
(3, 20.0, 1300000, N'11 Hoàng Hoa Thám', N'Ba Đình', N'Phòng nhỏ, giá rẻ cho sinh viên', 6),
(1, 28.0, 1700000, N'33 Lạc Long Quân', N'Tây Hồ', N'Gần Hồ Tây, phòng đẹp', 7),
(2, 60.0, 5000000, N'44 Xuân Thủy', N'Cầu Giấy', N'Nhà nguyên căn 3 tầng', 8),
(3, 15.0, 1000000, N'66 Tôn Đức Thắng', N'Đống Đa', N'Phòng rẻ, phù hợp sinh viên', 9),
(1, 35.0, 2200000, N'88 Kim Ngưu', N'Hai Bà Trưng', N'Phòng rộng, có ban công', 10);

-- DANHGIA (10 bản ghi)
INSERT INTO DANHGIA (MAND, MANT, TRANGTHAI, NOIDUNG) VALUES
(2,1,'LIKE',N'Phòng đẹp, chủ dễ tính'),
(3,1,'DISLIKE',N'Giá hơi cao'),
(4,2,'LIKE',N'Nhà sạch sẽ'),
(5,3,'LIKE',N'Phòng rẻ, phù hợp SV'),
(6,4,'DISLIKE',N'Hơi ồn'),
(7,5,'LIKE',N'Nhà rộng, thoáng'),
(8,6,'LIKE',N'Phòng nhỏ nhưng đủ dùng'),
(9,7,'DISLIKE',N'Xa trường'),
(10,8,'LIKE',N'Nhà nguyên căn đẹp'),
(1,9,'LIKE',N'Phòng giá tốt');

