USE QLDA;
GO

/* ================== BÀI 1 ================== */
-- Cách 1: Dùng biến vô hướng
DECLARE @Dai FLOAT, @Rong FLOAT;
DECLARE @DienTich FLOAT, @ChuVi FLOAT;

SET @Dai = 10;
SET @Rong = 5;

SET @DienTich = @Dai * @Rong;
SET @ChuVi = 2 * (@Dai + @Rong);

PRINT N'=== BÀI 1 - CÁCH 1 ===';
PRINT N'Chiều dài = ' + CAST(@Dai AS VARCHAR(10));
PRINT N'Chiều rộng = ' + CAST(@Rong AS VARCHAR(10));
PRINT N'Diện tích = ' + CAST(@DienTich AS VARCHAR(10));
PRINT N'Chu vi = ' + CAST(@ChuVi AS VARCHAR(10));

-- Cách 2: Dùng biến bảng
DECLARE @HinhChuNhat TABLE (
    Dai FLOAT,
    Rong FLOAT,
    DienTich FLOAT,
    ChuVi FLOAT
);

INSERT INTO @HinhChuNhat(Dai, Rong, DienTich, ChuVi)
VALUES (10, 5, 10*5, 2*(10+5));

PRINT N'=== BÀI 1 - CÁCH 2 ===';
SELECT * FROM @HinhChuNhat;
 
--Câu2.1
-- Tạo biến bảng để lưu mức lương cao nhất
DECLARE @MaxLuongTbl TABLE (LuongMax INT);

-- Ghi nhận lương cao nhất vào biến bảng
INSERT INTO @MaxLuongTbl
SELECT MAX(LUONG) 
FROM NHANVIEN;

-- Truy vấn nhân viên có lương cao nhất
SELECT NV.MANV, NV.HONV, NV.TENLOT, NV.TENNV, NV.LUONG
FROM NHANVIEN NV
JOIN @MaxLuongTbl M ON NV.LUONG = M.LuongMax;

--câu 2.2
DECLARE @LuongTBNC FLOAT;

-- Tính lương trung bình phòng "Nghiên cứu"
SELECT @LuongTBNC = AVG(LUONG)
FROM NHANVIEN NV
JOIN PHONGBAN PB ON NV.PHG = PB.MAPHG
WHERE PB.TENPHG = N'Nghiên cứu';

-- Lấy nhân viên có lương > trung bình phòng Nghiên cứu
SELECT HONV, TENLOT, TENNV, LUONG
FROM NHANVIEN NV
WHERE LUONG > @LuongTBNC;
--câu 2.3
DECLARE @LuongTB FLOAT = 30000;

SELECT PB.TENPHG, COUNT(*) AS SoLuongNV
FROM NHANVIEN NV
JOIN PHONGBAN PB ON NV.PHG = PB.MAPHG
GROUP BY PB.TENPHG
HAVING AVG(LUONG) > @LuongTB;

--câu 2.4
SELECT PB.TENPHG, COUNT(DA.MADA) AS SoDeAnChuTri
FROM PHONGBAN PB
LEFT JOIN DEAN DA ON PB.MAPHG = DA.PHONG
GROUP BY PB.TENPHG;


