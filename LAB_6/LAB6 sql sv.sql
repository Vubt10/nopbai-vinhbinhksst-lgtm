USE QLDA
GO
--Bài 1.1 Ràng buộc mức lương nhân viên khi thêm mới phải lớn hơn 15000 / Nếu không , hủy -> thông báo lương phải lớn hơn 15000
SELECT * FROM NHANVIEN
GO
--TABLE CHECKING--
CREATE OR ALTER TRIGGER CheckLuong_NV ON NHANVIEN
AFTER 
INSERT
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(
		SELECT 1
		FROM inserted
		WHERE LUONG < 15000)
		BEGIN
		PRINT N' Lương nhân viên phải lớn hơn 15000 theo quy định ! ';
		ROLLBACK TRANSACTION
		END
END
GO
--Tester
INSERT INTO NHANVIEN
VALUES('Phan','Viet','The','115','1967-01-11 00:00:00:000','778 nguyễn kiệm. TP hcm','Nam',5000,'005',4);
GO
--Bài 1.2 Ràng buộc độ tuổi của nhân viên mới từ 18 -> 65
SELECT * FROM NHANVIEN
GO
--TABLE CHECKING--
CREATE OR ALTER TRIGGER CheckTuoi_NV ON NHANVIEN
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Tuoi INT,@NgaySinh DATE
	SELECT @NgaySinh = NGSINH FROM inserted;
    SELECT @Tuoi = DATEDIFF(YEAR, @NgaySinh, GETDATE())
        - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @NgaySinh, GETDATE()), @NgaySinh) > GETDATE()
               THEN 1 ELSE 0 END;
		IF(@Tuoi <=18 OR @Tuoi >=65)
		BEGIN
		PRINT N'Lỗi ! Độ tuổi nhân viên phải từ 18 cho đến 65 theo quy định !';
		ROLLBACK TRANSACTION;
		END
END
GO
--Tester
INSERT INTO NHANVIEN
VALUES('Phan','Viet','The','199','2025-01-11 00:00:00:000','778 nguyễn kiệm. TP hcm','Nam',5000,'005',4);
GO
--Bài 1.3 Cập nhật nhân viên thì ràng buộc không cập nhật các nhân viên ở TP.HCM
SELECT * FROM NHANVIEN
GO
--TABLE CHECKING--
CREATE OR ALTER TRIGGER CapNhat_NV ON NHANVIEN
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(
		SELECT 1
		FROM inserted
		WHERE DCHI LIKE N'%TP HCM%')
		BEGIN
		PRINT N'Lỗi ! Không thể cập nhật nhân viên này !'
		ROLLBACK TRANSACTION
		END
END
GO
--Tester
UPDATE NHANVIEN
SET HONV = N'Nguyễn'
WHERE MANV = N'001'
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--Bài 2.1 Hiện tổng số Nam/Nữ mỗi khi thêm nhân viên mới vào bảng NHANVIEN
SELECT * FROM NHANVIEN
GO
--TABLE CHECKING--
CREATE OR ALTER TRIGGER ThongKeNamNu_NV ON NHANVIEN
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @MaleCount INT,@FemaleCount INT
	SELECT @MaleCount = COUNT(*) FROM NHANVIEN WHERE PHAI=N'Nam'
	SELECT @FemaleCount = COUNT(*) FROM NHANVIEN WHERE PHAI=N'Nữ'
	PRINT N'Tổng số nhân viên nam : ' + CAST(@MaleCount AS NVARCHAR(10))
	PRINT N'Tổng số nhân viên nữ : ' + CAST(@FemaleCount AS NVARCHAR(10))
END
GO
--Tester
INSERT INTO NHANVIEN
VALUES('Nguyễn','Vương','Gia','117','1999-11-11 00:00:00:000','778 nguyễn kiệm. TP hcm','Nam',25000,'005',4);
GO
--Bài 2.2 Hiện tổng số Nam/Nữ mỗi khi cập nhật giới tính nhân viên
SELECT * FROM NHANVIEN
GO
--TABLE CHECKING--
CREATE OR ALTER TRIGGER ThongKeNamNu_NV_02 ON NHANVIEN
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	IF (UPDATE(PHAI))
	BEGIN
	DECLARE @MaleCount INT,@FemaleCount INT
	SELECT @MaleCount = COUNT(*) FROM NHANVIEN WHERE PHAI=N'Nam'
	SELECT @FemaleCount = COUNT(*) FROM NHANVIEN WHERE PHAI=N'Nữ'
	PRINT N'Tổng số nhân viên nam : ' + CAST(@MaleCount AS NVARCHAR(10))
	PRINT N'Tổng số nhân viên nữ : ' + CAST(@FemaleCount AS NVARCHAR(10))
	END
END
GO
--Tester
UPDATE NHANVIEN
SET PHAI = N'Nam'
WHERE MANV = N'001'
--Bài 2.3 Hiện tổng số đề án mỗi nhân viên đã làm khi có hành động xóa trên bảng DEAN
--++ Vì cần phải có thao tác INSTEAD OF để thay thế DELETE từ DEAN thành cả DEAN và CONGVIEC ++--
SELECT * FROM DEAN
SELECT * FROM PHANCONG
SELECT * FROM NHANVIEN
SELECT * FROM CONGVIEC
GO
--TABLE CHECKING--
CREATE OR ALTER TRIGGER ThongKeDeAn_NV ON DEAN
AFTER DELETE
AS
BEGIN
	SET NOCOUNT ON;
SELECT 
        NV.MANV,
        NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV AS HOTEN,
        COUNT(DISTINCT PC.MADA) AS SoLuongDeAn
    FROM NHANVIEN NV
    LEFT JOIN PHANCONG PC ON NV.MANV = PC.MA_NVIEN
    LEFT JOIN DEAN D ON PC.MADA = D.MADA
    GROUP BY NV.MANV, NV.HONV, NV.TENLOT, NV.TENNV;
END
GO
--Tester
BEGIN TRANSACTION
DELETE FROM DEAN WHERE MADA = N'10'
ROLLBACK TRANSACTION
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--Bài 3.1 Xóa data trong bản thân nhân khi nhân viên có quan hệ bị xóa data
SELECT * FROM NHANVIEN
SELECT * FROM THANNHAN
GO
--TABLE CHECKING--
CREATE OR ALTER TRIGGER Delete_NV_ThanNhan ON NHANVIEN
INSTEAD OF DELETE
AS
BEGIN
	SET NOCOUNT ON;
	-- Xóa thân nhân có liên kết với nhân viên bị xóa 
	DELETE FROM THANNHAN
	WHERE MA_NVIEN IN (SELECT MANV FROM DELETED );
	-- Xóa nhân viên sau khi đã xóa thân nhân có liên kết 
	DELETE FROM NHANVIEN
	WHERE MANV IN ( SELECT MANV FROM DELETED );
END
GO
--Tester
DELETE FROM NHANVIEN WHERE MANV = N'?'
--Bài 3.2 Khi thêm mới nhân viên - mặc định họ được phân công vào đề án có MADA là 1
SELECT * FROM NHANVIEN
SELECT * FROM PHANCONG
GO
--TABLE CHECKING--
CREATE OR ALTER TRIGGER Insert_NV_PhanCong ON NHANVIEN
INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO NHANVIEN (HONV,TENLOT,TENNV,MANV,NGSINH,DCHI,PHAI,LUONG,MA_NQL,PHG)
	SELECT HONV,TENLOT,TENNV,MANV,NGSINH,DCHI,PHAI,LUONG,MA_NQL,PHG FROM inserted
	--
	INSERT INTO PHANCONG (MA_NVIEN,MADA)
	SELECT MANV,MADA=N'1' FROM inserted
	PRINT N'Nhập mới hoàn tất !'
END
GO
--Tester
INSERT INTO NHANVIEN (HONV,TENLOT,TENNV,MANV,NGSINH,DCHI,PHAI,LUONG,MA_NQL,PHG) VALUES (N'HỌ',N'TÊN LÓT',N'TÊN',N'MÃ NV',NGÀY SINH,N'ĐỊA CHỈ',N'PHÁI',LƯƠNG,N'MÃ NGƯỜI QUẢN LÝ',N'PHÒNG')