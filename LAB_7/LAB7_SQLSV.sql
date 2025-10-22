USE QLDA
GO
--lab7


--Bài 1: (4 điểm)
--Viết các hàm: 
--Nhập vào MaNV cho biết tuổi của nhân viên này. 
CREATE OR ALTER FUNCTION TuoiNhanVien (@MaNV NVARCHAR(9))
RETURNS INT
AS
BEGIN
    DECLARE @Tuoi INT;
    -- Tính tuổi dựa trên ngày sinh của nhân viên có mã @MaNV
    SELECT @Tuoi = DATEDIFF(YEAR, NGSINH, GETDATE())
    FROM NHANVIEN
    WHERE MANV = @MaNV
    RETURN @Tuoi
END
GO

SELECT dbo.TuoiNhanVien('001') AS [Tuổi nhân viên]
GO

--Nhập vào Manv cho biết số lượng đề án nhân viên này đã tham gia
CREATE OR ALTER FUNCTION SoLuongDeAn_NV (@MaNV NVARCHAR(9))
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT;
    SELECT @SoLuong = COUNT(DISTINCT MADA)
    FROM PHANCONG
    WHERE MA_NVIEN = @MaNV
    RETURN @SoLuong
END
GO

SELECT dbo.SoLuongDeAn_NV('001') AS [Số lượng đề án tham gia];
GO
--Truyền tham số vào phái nam hoặc nữ, xuất số lượng nhân viên theo phái
CREATE OR ALTER FUNCTION SoLuongNhanVien_TheoPhai (@Phai NVARCHAR(3))
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT
    SELECT @SoLuong = COUNT(*)
    FROM NHANVIEN
    WHERE PHAI = @Phai
    RETURN @SoLuong
END
GO

SELECT dbo.SoLuongNhanVien_TheoPhai(N'Nam') AS [Số lượng nhân viên nam]
SELECT dbo.SoLuongNhanVien_TheoPhai(N'Nữ') AS [Số lượng nhân viên nữ]
GO

--Truyền tham số đầu vào là tên phòng,
--tính mức lương trung bình của phòng đó,
--Cho biết họ tên nhân viên (HONV, TENLOT, TENNV)
--có mức lương trên mức lương trung bình của phòng đó. 
CREATE OR ALTER FUNCTION NhanVien_LuongCaoHonTB (@TenPhong NVARCHAR(30))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        NV.HONV,
        NV.TENLOT,
        NV.TENNV,
        NV.LUONG,
        PB.TENPHG AS [Tên phòng],
        -- Tính lương trung bình của phòng để hiển thị thêm nếu cần
        (SELECT AVG(NV.LUONG) 
         FROM NHANVIEN NV
         WHERE NV.PHG = PB.MAPHG) AS [LuongTB_Phong]
    FROM NHANVIEN NV
    JOIN PHONGBAN PB ON NV.PHG = PB.MAPHG
    WHERE PB.TENPHG = @TenPhong
      AND NV.LUONG > (
            SELECT AVG(NV.LUONG)
            FROM NHANVIEN NV
            WHERE NV.PHG = PB.MAPHG
        )
)
GO

SELECT * FROM dbo.NhanVien_LuongCaoHonTB(N'Nghiên cứu')
GO

--Tryền tham số đầu vào là Mã Phòng, cho biết tên phòng ban,
--họ tên người trưởng phòng và số lượng đề án mà phòng ban đó chủ trì.
CREATE OR ALTER FUNCTION ThongTin_PhongBan (@MaPhong INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        PB.TENPHG AS [Tên phòng ban],
        (NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV) AS [Họ tên trưởng phòng],
        COUNT(DA.MADA) AS [Số lượng đề án chủ trì]
    FROM PHONGBAN PB
    JOIN NHANVIEN NV ON PB.TRPHG = NV.MANV
    LEFT JOIN DEAN DA ON PB.MAPHG = DA.PHONG
    WHERE PB.MAPHG = @MaPhong
    GROUP BY PB.TENPHG, NV.HONV, NV.TENLOT, NV.TENNV
)
GO

SELECT * FROM dbo.ThongTin_PhongBan(5)
GO


--Bài 2: (4 điểm)*********************************************
--Tạo các view:
CREATE OR ALTER VIEW ThongTinNhanVien_Phong
AS
SELECT 
    NV.HONV,
    NV.TENNV,
    PB.TENPHG AS TenPHG,
    DDPH.DIADIEM AS DiaDiemPhg
FROM NHANVIEN NV
JOIN PHONGBAN PB ON NV.PHG = PB.MAPHG
JOIN DIADIEM_PHG DDPH ON PB.MAPHG = DDPH.MAPHG
GO

SELECT * FROM ThongTinNhanVien_Phong
GO

--Hiển thị thông tin TenNv, Lương, Tuổi. 
CREATE OR ALTER VIEW ThongTinLuongTuoi
AS
SELECT 
    TENNV,
    LUONG,
    YEAR(GETDATE()) - YEAR(NGSINH) 
        - CASE 
            WHEN MONTH(GETDATE()) < MONTH(NGSINH) 
              OR (MONTH(GETDATE()) = MONTH(NGSINH) AND DAY(GETDATE()) < DAY(NGSINH))
            THEN 1 
            ELSE 0 
          END AS Tuoi
FROM NHANVIEN
GO

-- Kiểm tra:
SELECT * FROM ThongTinLuongTuoi;
GO


--Hiển thị tên phòng ban và họ tên trưởng phòng của phòng ban có đông nhân viên nhất
SELECT TOP 1 
    PB.TENPHG AS [TenPhongBan],
    NV.HONV + ' ' + NV.TENLOT + ' ' + NV.TENNV AS [HoTenTruongPhong],
    COUNT(NV2.MANV) AS [SoLuongNhanVien]
FROM PHONGBAN PB
JOIN NHANVIEN NV ON PB.TRPHG = NV.MANV
JOIN NHANVIEN NV2 ON PB.MAPHG = NV2.PHG
GROUP BY PB.TENPHG, NV.HONV, NV.TENLOT, NV.TENNV
ORDER BY COUNT(NV2.MANV) DESC
