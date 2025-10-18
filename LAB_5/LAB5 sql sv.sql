--Bài 1 In tên Tiếng Việt
CREATE OR ALTER PROC sp_Ten 
    @ten NVARCHAR(50)
AS
BEGIN
    PRINT N'Xin chào : ' + CAST(@ten as NVARCHAR(50))
END
EXEC sp_Ten N'Tấn Phát'
GO
--Bài 1.2 Tính tổng 
CREATE OR ALTER PROC sp_TinhTong
    @so1 INT,
    @so2 INT
AS
BEGIN
    DECLARE @tong INT
    SET @tong = @so1 + @so2
    PRINT N'Tổng là: ' + CAST(@tong AS NVARCHAR(10))
END
EXEC sp_TinhTong 5,8
GO
--Bài 1.3 nhập n - tính tổng các số chẵn từ 1->n
CREATE OR ALTER PROC sp_TongSoChan
    @n INT
AS
BEGIN
    DECLARE 
    @i INT = 1, 
    @tong INT = 0
    WHILE @i <= @n
    BEGIN
        IF @i % 2 = 0
            SET @tong = @tong + @i
            SET @i = @i + 1
    END

    PRINT N'Tổng các số chẵn từ 1 đến ' + CAST(@n AS NVARCHAR(10)) + N' là: ' + CAST(@tong AS NVARCHAR(10))
END
EXEC sp_TongSoChan 50
GO
--Bài 1.4 nhập 2 số , tìm UCLN
CREATE OR ALTER PROC sp_UCLN
    @a INT,
    @b INT
AS
BEGIN
    DECLARE @temp INT
    IF @a > @b
    BEGIN
        SET @temp = @a
        SET @a = @b
        SET @b = @temp
END
WHILE @a <> 0
    BEGIN
        SET @temp = @a
        SET @a = @b % @a
        SET @b = @temp
    END
    PRINT N'Ước chung lớn nhất là: ' + CAST(@b AS NVARCHAR(10))
END
EXEC sp_UCLN 10,20
GO
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
USE QLDA
GO
--Bài 2.1 Nhập @MaNV -> Xuất thông tin của @MaNV
SELECT * FROM NHANVIEN
GO
--TABLE CHECKING--
CREATE OR ALTER PROC sp_thongTinNV
    @MaNV NVARCHAR(10)
AS
BEGIN
    SELECT * FROM NHANVIEN WHERE MANV = @MaNV;
END
EXEC sp_thongTinNV N'001'
GO
--Bài 2.2 Nhập @MaDA -> Xuất số lượng nhân viên tham dự DA đó
SELECT * FROM DEAN
SELECT * FROM PHANCONG
GO
--TABLE CHECKING--
CREATE OR ALTER PROC sp_soLuongNV
    @MaDA NVARCHAR(10)
AS
BEGIN
    SELECT COUNT(*) AS N'Tổng số nhân viên' FROM PHANCONG WHERE MADA = @MaDA;
END
EXEC sp_soLuongNV N'10'
GO
--Bài 2.3 Nhập @MaDA và @dDiem_DA -> Xuất số lượng nhân viên có đủ 2 y/c nhập trên
SELECT * FROM DEAN
SELECT * FROM PHANCONG
GO
--TABLE CHECKING--
CREATE OR ALTER PROC sp_soLuongNV_02
    @MaDA NVARCHAR(10),
    @Ddiem_DA NVARCHAR(50)
AS
BEGIN
    SELECT COUNT(DISTINCT pc.MA_NVIEN) AS SoLuongNhanVien
    FROM PHANCONG pc JOIN DEAN da ON pc.MADA = da.MADA
    WHERE da.MADA = @MaDA AND da.DDIEM_DA = @Ddiem_DA;
END
EXEC sp_SoLuongNV_02 N'10', N'Hà Nội';
GO
--Bài 2.4 Nhập @MaTrPhg -> Xuất thông tin nhân viên ở phòng có trưởng phòng là @MaTrPhg + không có thân nhân
SELECT * FROM PHONGBAN
SELECT * FROM THANNHAN
SELECT * FROM NHANVIEN
GO
--TABLE CHECKING--
CREATE OR ALTER PROC sp_TongNhanVienTheoTrPhgNThanNhan
    @MaTrPhg NVARCHAR(10)
AS
BEGIN
    SELECT
    nv.MANV,nv.HONV,nv.TENLOT,nv.TENNV,nv.NGSINH,nv.PHAI,nv.DCHI,nv.LUONG
    FROM NHANVIEN nv JOIN PHONGBAN pb ON nv.MANV = pb.MAPHG
    LEFT JOIN THANNHAN tn ON nv.MANV = tn.MA_NVIEN
    WHERE pb.TRPHG = @MaTrPhg AND tn.MA_NVIEN IS NULL;
END
EXEC sp_TongNhanVienTheoTrPhgNThanNhan N'008'
GO
--Bài 2.5 nhập @MaNV và @MaPB -> Ktra nhân viên có @MaNV có ở trong phòng ban có @MaPB hay không ?
SELECT * FROM PHONGBAN
SELECT * FROM NHANVIEN
GO
--TABLE CHECKING--
CREATE OR ALTER PROC sp_KiemTraNV
    @MaNV NVARCHAR(10),
    @MaPB NVARCHAR(10)
AS
BEGIN 
    IF EXISTS (
        SELECT 1
        FROM NHANVIEN
        WHERE MANV = @Manv AND PHG = @MaPB
    )
        PRINT N'Nhân viên ' + @MaNV + N' thuộc phòng ban ' + @MaPB + N'.';
    ELSE
        PRINT N'Nhân viên ' + @MaNV + N' không thuộc phòng ban ' + @MaPB + N'.';
END
EXEC sp_KiemTraNV N'001',N'5'
GO
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Bài 3.1 Thêm dữ liệu vào database [ PHONGBAN ] / các giá trị được thêm vào dưới dạng tham số đầu vào / kiểm tra nếu trùng MaPhg thì báo thêm thất bại
SELECT * FROM PHONGBAN
GO
--TABLE CHECKING--
CREATE OR ALTER PROC sp_ThemPhongBan
    @TenPhg NVARCHAR(50),
    @MaPhg NVARCHAR(50),
    @TrPhg NVARCHAR(50),
    @Ng_NhanChuc DATE
AS
BEGIN
    IF EXISTS(
        SELECT 1 
        FROM PHONGBAN 
        WHERE MAPHG = @MaPhg)
    PRINT N'Thêm thất bại phòng với mã phòng [' + @MaPhg + N'] vì phòng đã tồn tại !';
    ELSE
    BEGIN
        INSERT INTO PHONGBAN (TENPHG,MAPHG,TRPHG,NG_NHANCHUC) VALUES (@TenPhg,@MaPhg,@TrPhg,@Ng_NhanChuc);
    PRINT N'Thêm phòng ban thành công !'
    END
END
EXEC sp_ThemPhongBan N'CNTT',N'3',N'008','1999-09-19'
--Bài 3.2 Cập nhật tên phòng ban ( CNTT thành IT )
SELECT * FROM PHONGBAN
GO
--TABLE CHECKING--
CREATE OR ALTER PROC sp_DoiTenPhongBan
    @TenPhg NVARCHAR(50),
    @TenPhgMoi NVARCHAR(50)
AS
BEGIN
    IF EXISTS(
        SELECT 1
        FROM PHONGBAN
        WHERE TENPHG = @TenPhg)
    BEGIN
    UPDATE PHONGBAN SET TENPHG = @TenPhgMoi WHERE TENPHG = @TenPhg;
    PRINT N'Cập nhật tên phòng ban thành công !';
    END
    ELSE
    BEGIN
    PRINT N'Không thể tìm thấy phòng ban '+ @TenPhg;
    END
END
EXEC sp_DoiTenPhongBan N'CNTT',N'TESTING'
--Bài 3.3 Thêm nhân viên vào csdl với các y/c : thuộc phòng IT / Lương < 25k - được nhân viên có mã 009 quản lý || >25k - được " mã 005 " / Nam - tuổi 18-65 || Nữ - tuổi 18-60
SELECT * FROM NHANVIEN
GO
--TABLE CHECKING--
CREATE OR ALTER PROC sp_ThemNhanVien
    @HoNV NVARCHAR(50),
    @TenLot NVARCHAR(50),
    @TenNV NVARCHAR(50),
    @MaNV NVARCHAR(50),
    @NgaySinh DATE,
    @DiaChi NVARCHAR(100),
    @Phai NVARCHAR(50),
    @Luong DECIMAL(10,2),
    @MaNQL NVARCHAR(50) = null,
    @Phong NVARCHAR(50)
AS
BEGIN
    --Kiểm tra mã nhân viên
    IF EXISTS(
        SELECT 1
        FROM NHANVIEN
        WHERE MANV = @MaNV)
        PRINT N'Mã nhân viên đã tồn tại ! Cập nhật thất bại !';
        RETURN;
    --Theo y/c - phải là nhân viên thuộc phòng ban IT 
    IF @Phong <> N'IT'
        BEGIN 
        PRINT N'Không thể thêm nhân viên ngoài bộ phận IT trong thời gian này - - -';
        RETURN;
        END
    --Theo y/c - xét lương để hướng đúng tới người quản lý
    IF @Luong < 25000
        BEGIN
        SET @MaNQL = N'009'
        END
    ELSE
        BEGIN
        SET @MaNQL = N'005'
        END
    --Theo y/c - xét tuổi tác của nhân viên tùy vào giới tính của họ
    DECLARE @Tuoi INT;
        SELECT @Tuoi = DATEDIFF(YEAR, @NgaySinh, GETDATE()) 
            -CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @NgaySinh, GETDATE()), @NgaySinh) > GETDATE() 
            THEN 1 ELSE 0 END;
    IF (@Phai = N'Nam' AND (@Tuoi < 18 OR @Tuoi > 65))
        BEGIN
            PRINT N'Lỗi: Tuổi của nhân viên Nam phải từ 18 đến 65!';
            RETURN;
        END
    IF (@Phai = N'Nữ' AND (@Tuoi < 18 OR @Tuoi > 60))
        BEGIN
            PRINT N'Lỗi: Tuổi của nhân viên Nữ phải từ 18 đến 60!';
            RETURN;
        END
    ELSE
        BEGIN
        INSERT INTO NHANVIEN(HONV,TENLOT,TENNV,MANV,NGSINH,DCHI,PHAI,LUONG,MA_NQL,PHG) 
        VALUES ( @HoNV,@TenLot,@TenNV,@MaNV,@NgaySinh,@DiaChi,@Phai,@Luong,@MaNQL,@Phong);
        PRINT N'Cập nhật thành công!';
        END
END