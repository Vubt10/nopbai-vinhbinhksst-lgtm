USE QLNHATRO_hytruong;
GO


   --Y3 – CÁC CHỨC NĂNG (ĐÃ CHỈNH THEO CẤU TRÚC CỦA BẠN)

-- 1️⃣ Thêm thông tin vào các bảng

-- SP thêm người dùng
CREATE OR ALTER PROCEDURE sp_ThemNguoiDung
    @TenND NVARCHAR(100),
    @GioiTinh NVARCHAR(10),
    @DienThoai VARCHAR(15),
    @DiaChi NVARCHAR(200),
    @Quan NVARCHAR(50),
    @Email VARCHAR(100)
AS
BEGIN
    IF @TenND IS NULL OR @GioiTinh IS NULL OR @DienThoai IS NULL 
       OR @DiaChi IS NULL OR @Quan IS NULL OR @Email IS NULL
    BEGIN
        PRINT N'Vui lòng nhập đầy đủ thông tin người dùng!';
        RETURN;
    END

    INSERT INTO NGUOIDUNG (TENND, GIOITINH, DIENTHOAI, DIACHI, QUAN, EMAIL)
    VALUES (@TenND, @GioiTinh, @DienThoai, @DiaChi, @Quan, @Email);

    PRINT N'Thêm người dùng thành công!';
END
GO

EXEC sp_ThemNguoiDung N'Nguyễn Lan', N'Nữ', '0909123456', N'12 Phạm Văn Đồng', N'Cầu Giấy', 'lannguyen@gmail.com';
EXEC sp_ThemNguoiDung NULL, N'Nữ', '0909123456', N'12 Phạm Văn Đồng', N'Cầu Giấy', 'lannguyen@gmail.com';
GO

-- SP thêm nhà trọ
CREATE OR ALTER PROCEDURE sp_ThemNhaTro
    @MaLoai INT,
    @DienTich DECIMAL(10,2),
    @GiaPhong DECIMAL(18,0),
    @DiaChi NVARCHAR(200),
    @Quan NVARCHAR(50),
    @MoTa NVARCHAR(500),
    @NgayDang DATE,
    @NguoiLienHe INT
AS
BEGIN
    IF @MaLoai IS NULL OR @DienTich IS NULL OR @GiaPhong IS NULL OR @DiaChi IS NULL OR @Quan IS NULL OR @NguoiLienHe IS NULL
    BEGIN
        PRINT N'Vui lòng nhập đầy đủ thông tin nhà trọ!';
        RETURN;
    END

    INSERT INTO NHATRO (MALOAINHA, DIENTICH, GIAPHONG, DIACHI, QUAN, MOTA, NGAYDANG, NGUOILIENHE)
    VALUES (@MaLoai, @DienTich, @GiaPhong, @DiaChi, @Quan, @MoTa, @NgayDang, @NguoiLienHe);

    PRINT N'Thêm nhà trọ thành công!';
END
GO

EXEC sp_ThemNhaTro 1, 25, 1500000, N'25 Nguyễn Trãi', N'Thanh Xuân', N'Phòng khép kín', '2025-10-21', 1;
EXEC sp_ThemNhaTro NULL, 25, 1500000, N'25 Nguyễn Trãi', N'Thanh Xuân', N'Phòng khép kín', '2025-10-21', 1;
GO

-- SP thêm đánh giá
CREATE OR ALTER PROCEDURE sp_ThemDanhGia
    @MAND INT,
    @MANT INT,
    @TrangThai NVARCHAR(10),
    @NoiDung NVARCHAR(200)
AS
BEGIN
    IF @MAND IS NULL OR @MANT IS NULL OR @TrangThai IS NULL
    BEGIN
        PRINT N'Vui lòng nhập đầy đủ thông tin đánh giá!';
        RETURN;
    END

    INSERT INTO DANHGIA (MAND, MANT, TRANGTHAI, NOIDUNG)
    VALUES (@MAND, @MANT, @TrangThai, @NoiDung);

    PRINT N'Thêm đánh giá thành công!';
END
GO

EXEC sp_ThemDanhGia 1, 1, N'LIKE', N'Phòng đẹp, thoáng mát';
EXEC sp_ThemDanhGia NULL, 1, N'LIKE', N'Phòng đẹp, thoáng mát';
GO


---------------------------------------------------
-- 2️⃣ Truy vấn thông tin
---------------------------------------------------

-- SP tìm kiếm nhà trọ
CREATE OR ALTER PROCEDURE sp_TimKiemNhaTro
    @Quan NVARCHAR(50) = NULL,
    @MinDienTich DECIMAL(10,2) = NULL,
    @MaxDienTich DECIMAL(10,2) = NULL,
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @MinGia DECIMAL(18,0) = NULL,
    @MaxGia DECIMAL(18,0) = NULL,
    @MaLoai INT = NULL
AS
BEGIN
    SELECT 
        N'Cho thuê phòng trọ tại ' + nt.DIACHI + N', ' + nt.QUAN AS [Thông tin phòng],
        CAST(nt.DIENTICH AS NVARCHAR(10)) + N' m2' AS [Diện tích],
        FORMAT(nt.GIAPHONG, '#,##0') AS [Giá phòng],
        nt.MOTA AS [Mô tả],
        FORMAT(nt.NGAYDANG, 'dd-MM-yyyy') AS [Ngày đăng],
        CASE nd.GIOITINH 
            WHEN N'Nam' THEN N'A. ' + nd.TENND
            WHEN N'Nữ' THEN N'C. ' + nd.TENND
        END AS [Người liên hệ],
        nd.DIENTHOAI AS [Điện thoại],
        nd.DIACHI AS [Địa chỉ liên hệ]
    FROM NHATRO nt
    JOIN NGUOIDUNG nd ON nt.NGUOILIENHE = nd.MAND
    WHERE
        (@Quan IS NULL OR nt.QUAN = @Quan)
        AND (@MaLoai IS NULL OR nt.MALOAINHA = @MaLoai)
        AND (@MinDienTich IS NULL OR nt.DIENTICH >= @MinDienTich)
        AND (@MaxDienTich IS NULL OR nt.DIENTICH <= @MaxDienTich)
        AND (@TuNgay IS NULL OR nt.NGAYDANG >= @TuNgay)
        AND (@DenNgay IS NULL OR nt.NGAYDANG <= @DenNgay)
        AND (@MinGia IS NULL OR nt.GIAPHONG >= @MinGia)
        AND (@MaxGia IS NULL OR nt.GIAPHONG <= @MaxGia);
END
GO

EXEC sp_TimKiemNhaTro @Quan = N'Cầu Giấy';
EXEC sp_TimKiemNhaTro @MinGia = 1000000, @MaxGia = 2000000;
GO


-- Hàm tìm người dùng
CREATE OR ALTER FUNCTION f_TimNguoiDung(
    @TenND NVARCHAR(100),
    @GioiTinh NVARCHAR(10),
    @DienThoai VARCHAR(15),
    @DiaChi NVARCHAR(200),
    @Quan NVARCHAR(50),
    @Email VARCHAR(100)
)
RETURNS INT
AS
BEGIN
    DECLARE @Ma INT;
    SELECT @Ma = MAND
    FROM NGUOIDUNG
    WHERE TENND = @TenND AND GIOITINH = @GioiTinh
      AND DIENTHOAI = @DienThoai AND DIACHI = @DiaChi
      AND QUAN = @Quan AND EMAIL = @Email;
    RETURN @Ma;
END
GO


-- Hàm tổng LIKE / DISLIKE
CREATE OR ALTER FUNCTION f_TongLikeDislike(@MaNhaTro INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        SUM(CASE WHEN TRANGTHAI = 'LIKE' THEN 1 ELSE 0 END) AS SoLike,
        SUM(CASE WHEN TRANGTHAI = 'DISLIKE' THEN 1 ELSE 0 END) AS SoDislike
    FROM DANHGIA
    WHERE MANT = @MaNhaTro
);
GO


-- View top 10 nhà trọ được LIKE nhiều nhất
CREATE OR ALTER VIEW v_Top10NhaTroLike AS
SELECT TOP 10 
    nt.MANT, nt.DIENTICH, nt.GIAPHONG, nt.MOTA, nt.NGAYDANG,
    nd.TENND, nd.DIACHI, nd.DIENTHOAI, nd.EMAIL,
    COUNT(CASE WHEN dg.TRANGTHAI = 'LIKE' THEN 1 END) AS TongLike
FROM NHATRO nt
JOIN NGUOIDUNG nd ON nt.NGUOILIENHE = nd.MAND
LEFT JOIN DANHGIA dg ON nt.MANT = dg.MANT
GROUP BY nt.MANT, nt.DIENTICH, nt.GIAPHONG, nt.MOTA, nt.NGAYDANG,
         nd.TENND, nd.DIACHI, nd.DIENTHOAI, nd.EMAIL
ORDER BY TongLike DESC;
GO


-- SP xem đánh giá
CREATE OR ALTER PROCEDURE sp_XemDanhGia
    @MaNhaTro INT
AS
BEGIN
    SELECT 
        dg.MANT, nd.TENND AS [Người đánh giá], dg.TRANGTHAI, dg.NOIDUNG
    FROM DANHGIA dg
    JOIN NGUOIDUNG nd ON dg.MAND = nd.MAND
    WHERE dg.MANT = @MaNhaTro;
END
GO

EXEC sp_XemDanhGia 1;
GO


---------------------------------------------------
-- 3️⃣ Xóa thông tin (Transaction)
---------------------------------------------------

-- SP xóa nhà trọ có nhiều DISLIKE
CREATE OR ALTER PROCEDURE sp_XoaNhaTroTheoDislike
    @SoDislike INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DELETE FROM DANHGIA
        WHERE MANT IN (
            SELECT MANT FROM (
                SELECT MANT, COUNT(*) AS SL
                FROM DANHGIA WHERE TRANGTHAI = 'DISLIKE'
                GROUP BY MANT
            ) AS t WHERE t.SL > @SoDislike
        );

        DELETE FROM NHATRO
        WHERE MANT IN (
            SELECT MANT FROM (
                SELECT MANT, COUNT(*) AS SL
                FROM DANHGIA WHERE TRANGTHAI = 'DISLIKE'
                GROUP BY MANT
            ) AS t WHERE t.SL > @SoDislike
        );

        COMMIT TRANSACTION;
        PRINT N'Đã xóa thành công các nhà trọ có nhiều DISLIKE.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'Lỗi khi xóa dữ liệu!';
    END CATCH
END
GO


-- SP xóa nhà trọ theo khoảng thời gian đăng tin
CREATE OR ALTER PROCEDURE sp_XoaNhaTroTheoThoiGian
    @TuNgay DATE, @DenNgay DATE
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DELETE FROM DANHGIA
        WHERE MANT IN (
            SELECT MANT FROM NHATRO
            WHERE NGAYDANG BETWEEN @TuNgay AND @DenNgay
        );

        DELETE FROM NHATRO
        WHERE NGAYDANG BETWEEN @TuNgay AND @DenNgay;

        COMMIT TRANSACTION;
        PRINT N'Đã xóa thành công các nhà trọ đăng trong khoảng thời gian chọn.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'Lỗi khi xóa dữ liệu!';
    END CATCH
END
GO
-----------------------------------------------------------------------------
--Y4: Quản trị cơ sở dữ liệu


USE QLNHATRO_hytruong;
GO
---------------------------------------------------
-- 1️⃣ XÓA LOGIN & USER CŨ (nếu đã tồn tại)
---------------------------------------------------

-- Xóa user trong database (nếu có)
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'QLNHATRO_Admin')
    DROP USER QLNHATRO_Admin;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'QLNHATRO_User')
    DROP USER QLNHATRO_User;
GO

-- Xóa login ở server (nếu có)
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'QLNHATRO_Admin')
    DROP LOGIN QLNHATRO_Admin;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'QLNHATRO_User')
    DROP LOGIN QLNHATRO_User;
GO

---------------------------------------------------
-- 2️⃣ TẠO LOGIN & USER MỚI
---------------------------------------------------

-- Tạo tài khoản đăng nhập (login)
CREATE LOGIN QLNHATRO_Admin 
WITH PASSWORD = 'Admin@123',
CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO

CREATE LOGIN QLNHATRO_User 
WITH PASSWORD = 'User@123',
CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
GO

-- Tạo user tương ứng trong database QLNHATRO_hytruong
USE QLNHATRO_hytruong;
CREATE USER QLNHATRO_Admin FOR LOGIN QLNHATRO_Admin;
CREATE USER QLNHATRO_User FOR LOGIN QLNHATRO_User;
GO

---------------------------------------------------
-- 3️⃣ PHÂN QUYỀN CHO NGƯỜI DÙNG
---------------------------------------------------

-- QLNHATRO_Admin: toàn quyền (db_owner)
ALTER ROLE db_owner ADD MEMBER QLNHATRO_Admin;
GO

-- QLNHATRO_User: quyền thao tác và thực thi thủ tục/hàm
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, VIEW DEFINITION 
ON DATABASE::QLNHATRO_hytruong TO QLNHATRO_User;
GO

---------------------------------------------------
-- 4️⃣ KIỂM TRA USER TRONG DATABASE (tuỳ chọn)
---------------------------------------------------
SELECT name AS TenUser, type_desc AS Loai, create_date AS NgayTao
FROM sys.database_principals
WHERE type IN ('S', 'U')
ORDER BY create_date;
GO

---------------------------------------------------
-- 5️⃣ SAO LƯU (BACKUP) DATABASE
---------------------------------------------------
-- 🔹 Lưu file backup ra Desktop (đảm bảo bạn có quyền ghi)
-- 🔹 Thay <TênMáy> bằng tên thư mục người dùng Windows của bạn

DECLARE @BackupPath NVARCHAR(200);
SET @BackupPath = 'D:\SQL Server\QLNHATRO_hytruong.bak';

BACKUP DATABASE QLNHATRO_hytruong
TO DISK = @BackupPath
WITH INIT, NAME = N'Backup database QLNHATRO_hytruong';

PRINT N'Sao lưu CSDL thành công → ' + @BackupPath;
GO
----
