
	
CREATE DATABASE MUAHANG
GO

USE MUAHANG
GO

CREATE TABLE CUSTOMER  ( 
	id_customer  NVARCHAR(10) NOT NULL,
  	id_orders 	 nvarchar(10) not NULL,
	name_customer    NVARCHAR(50) NOT NULL , 
	email_customer 	 NVARCHAR(50) NOT NULL ,
	phone_customer 	 NVARCHAR(50) not null ,
	address_customer   NVARCHAR(50) not null ,
	CONSTRAINT pk_CUSTOMER PRIMARY KEY(id_customer)
) 
	
CREATE TABLE PRODUCT (
	id_product   nvarchar(10) NOT NULL,
	name_product nvarchar(50) NOT NULL,
	des_product  nvarchar(50) NOT NULL,
	price_product money NOT NULL,
	num_product   int NOT NULL,
	CONSTRAINT pk_PRODUCT PRIMARY KEY (id_product)
)

Create Table ORDERS
	(
	id_orders nvarchar(10) not NULL,
    id_payment nvarchar(10) not null,
    id_orderDetail NVARCHAR(10) NOT NULL, 
	nameDate_orders date not NULL, -- ngày đặt hàng 
	des_orders  nvarchar(50) ,
	status_orders money ,		-- tạm gọi tổng tiền 
	CONSTRAINT pk_ORDERS PRIMARY KEY (id_orders)
)

create table PAYMENT
(
	id_payment nvarchar(10) not null ,
	name_payment nvarchar(50) not NULL,
	fee_payment money ,  -- phí thanh toán 
    CONSTRAINT pk_PAYMENT PRIMARY KEY (id_payment)
)

CREATE TABLE ORDERDETAIL  ( 
	id_orderDetail     NVARCHAR(10) NOT NULL, 
  	id_product   nvarchar(10) NOT NULL,
	num_orderDetail    INT , 
	price_orderDetail  MONEY ,
  	amount_orderDetail money , -- thành tiền 
	CONSTRAINT pk_ORDERDETAIL PRIMARY KEY(id_orderDetail)
)

alter table CUSTOMER
add foreign key(id_orders) references ORDERS(id_orders);

alter table ORDERS
add foreign key(id_payment) references PAYMENT(id_payment);

alter table ORDERS
add FOREIGN key(id_orderDetail) references ORDERDETAIL(id_orderDetail);

alter table ORDERDETAIL
add FOREIGN key(id_product) references PRODUCT(id_product);


insert into CUSTOMER 
	(id_customer, id_orders, name_customer, email_customer, phone_customer, address_customer) values
	('KH001', 'OD001', 'Hai',   'hai@gmail.com' , '0987654' , 'Da Nang'),
	('KH002', 'OD003', 'Bao',   'ba@gmail.com', '0987655', 'Hue'),
	('KH003', 'OD001', 'Huy', 	'huy@gmail.com', '0987656', 'Quang Nam'),
	('KH004', 'OD002', 'Chinh',  'chinh@gmail.com', '0987657', 'Quang Ngai'),
	('KH005', 'OD002', 'Nhung',   'nhung@gmail.com', '0987658', 'Da Nang') 	
	
INSERT INTO PRODUCT (id_product, name_product, des_product, price_product, num_product) VALUES
	('PR001', 'Tui Da', 'da', 195000,	100),
	('PR002', 'Vong Tay', 'thuy tinh', 400000, 50),
	('PR003', 'Nhan', 'kim cuong', 7000000, 10)    
    
insert into ORDERS (id_orders, id_payment, id_orderDetail, nameDate_orders, des_orders, status_orders) values 
	('OD001', 'P001', 'ODD01', '01/01/2020', 'da thanh toan', 250000),
	('OD002', 'P003', 'ODD05', '02/11/2021', 'huy', 400000),
	('OD003', 'P002', 'ODD02', '03/04/2020', 'tra gop', 700000)
    
INSERT INTO PAYMENT(id_payment, name_payment, fee_payment) VALUES
	('P001','Visa',300000),
    ('P002','Master Card',350000),
	('P003','tien mat',515000)
	
insert into ORDERDETAIL (id_orderDetail, id_product, num_orderDetail, price_orderDetail, amount_orderDetail) values
	('ODD01', 'PR001', 1, 100000, 100000),
	('ODD02', 'PR003', 2, 520000 ,1040000),
	('ODD03', 'PR002', 5, 125000, 625000),
	('ODD04', 'PR002', 1, 135000, 135000),
	('ODD05', 'PR003', 3, 200000 ,60000)
	

-- view : 
-- tạo khung nhìn lấy thông tin khách hàng đã từng đặt hàng 
-- ngày 01/01/2020 
create view V_infoCustomer2020 as select c.* from CUSTOMER c 
	join ORDERS o on c.id_orders = o.id_orders 
	where o.nameDate_orders = '01/01/2020' ;

	select * from V_infoCustomer2020 ;
	drop view V_infoCustomer2020;

-- view : 
-- tạo khung nhìn lấy thông tin những sản phẩm có mô tả là 'thuy tinh' và
-- số lượng mua từ 5 sản phẩm trở lên 
create view V_infoProduct5 as select p.* from PRODUCT p
	join ORDERDETAIL odd on p.id_product = odd.id_product 
    where p.des_product = 'thuy tinh' and odd.num_orderDetail >= 5 ;
    
    select * from V_infoProduct5 ;
    drop VIEW V_infoProduct5;


-- user define function : 
-- tạo function với yêu cầu: đếm tổng số lượng sản phẩm 'Vong Tay'
-- đã bán ra 

create FUNCTION  funcSumPro()
  returns int as 
	begin
        return (select sum(odd.num_orderdetail) as SumPro from ORDERDETAIL odd     
		where odd.id_product in (select id_product from PRODUCT p 
        where p.name_product = 'Vong Tay')  );
	end ;

	-- gọi hàm 
	select dbo.funcSumPro() ; 	
	drop function dbo.funcSumPro ; 

-- user define function :
-- 


-- STORED PROCEDURE  : 
-- tạo Procedure để bổ sung bảng ghi mới vào bảng ORDERS 
-- kiểm tra tính lệ của dữ liệu được bổ sung, với nguyên tắc là  
-- không được trùng khóa chính và đảm bảo tòan vẹn tham chiếu 
-- đến các bảng liên quan . 

create procedure Sp_insertOrder(@id_orders nvarchar(10), @id_payment nvarchar(10),
								@id_orderDetail nvarchar(10), @nameDate_orders date,
								@des_orders nvarchar(50), @status_orders money)
	as 
		begin
			if exists (select o.id_orders from ORDERS o where o.id_orders= @id_orders)
						begin 
							print N'Mã orders đã được sử dụng! ' 
							return 
						end
			if not exists (select p.id_payment from PAYMENT p 
					where p.id_payment = @id_payment)
						begin 
							print N'không có mã Payment này! ' 
							return 
						end 
			if not exists (select odd.id_orderDetail from ORDERDETAIL odd 
					where odd.id_orderDetail = @id_orderDetail)
						begin 
							print N'không có mã orderdDetail này! ' 
							return 
						end
					insert into ORDERS values 
						(@id_orders, @id_payment,
						 @id_orderDetail, @nameDate_orders,
						 @des_orders, @status_orders)
		end;

	execute dbo.Sp_insertOrder 
	'OD004', 'P002', 'ODD04', '01/01/2020', 'huy', '375000'; -- dl Hợp lệ 

	execute dbo.Sp_insertOrder 
	'OD003', 'P2', 'ODD04', '01/01/2020', 'huy', '375000'; -- dl không Hợp lệ 

	delete ORDERS where id_orders = 'OD004'; 
	select * from ORDERS ;
	drop proc Sp_insertOrder;

-- STORED PROCEDURE
-- Dùng để xóa thông tin của một khách hàng nào đó (tức là xóa 1 bản ghi trong bảng CUSTOMER) 
-- vớimã khách hàng được truyền vào như một tham số của Stored Procedure

create procedure Sp_deleCus (@id_cus nvarchar(10)) 
	as 
	 begin 
		delete from CUSTOMER where CUSTOMER.id_customer = @id_cus ;  
	 end  ;
 
	execute Sp_deleCus 'KH005' ;
	select * from CUSTOMER;
	insert into CUSTOMER (id_customer, id_orders, name_customer, email_customer, phone_customer, address_customer) values
	('KH005', 'OD002', 'Nhung',   'nhung@gmail.com', '0987658', 'Da Nang') 
--
CREATE TRIGGER Trigger_3
ON CUSTOMER
FOR UPDATE, INSERT
AS
BEGIN
	PRINT N'Nhập thành công'
END
GO

insert into CUSTOMER 
	(id_customer, id_orders, name_customer, email_customer, phone_customer, address_customer) values
	('KH006', 'OD002', 'Tinh',   'tinh@gmail.com', '0987658', 'Da Nang')
	--
	CREATE TRIGGER Trigger_2
ON CUSTOMER
FOR DELETE
AS
BEGIN
	DECLARE @tong int
	SELECT @tong = COUNT(*) FROM CUSTOMER
	PRINT N'Tổng số bản ghi còn lại của bảng CUSTOMER la: '+ CAST(@tong AS varchar(5))
END
GO

SELECT * FROM dbo.CUSTOMER
DELETE FROM dbo.CUSTOMER WHERE address_customer='Da Nang'
Nguyễn
Tú Nguyễn
-- STORED PROCEDURE : 
-- Tạo 1 stored Procedure khi có 1 khách hàng mới mua hàng thì thêm một hóa đơn mới 
-- kiểm tra tính hợp lệ của dữ liệu được thêm, với nguyên tắc là  
-- hóa đơn mới nên không được trùng khóa chính và đảm bảo 
-- toàn vẹn tham chiếu đến các bảng khác  

create procedure Sp_insertOrder(@id_orders nvarchar(10), @id_payment nvarchar(10),
								@id_orderDetail nvarchar(10), @nameDate_orders date,
								@des_orders nvarchar(50), @status_orders money)
	as 
		begin
			if exists (select o.id_orders from ORDERS o where o.id_orders= @id_orders)
						begin 
							print N'Mã hóa đơn này đã được sử dụng! ' 
							return 
						end
			if not exists (select p.id_payment from PAYMENT p 
					where p.id_payment = @id_payment)
						begin 
							print N'không có mã hình thức thanh toán này! ' 
							return 
						end 
			if exists (select od.id_orderDetail from ORDERS od join ORDERDETAIL odd 
							on od.id_orderDetail = odd.id_orderDetail where od.id_orderDetail = @id_orderDetail )
						begin 
							print N'mã chi tiết hóa đơn đã được dùng! ' 
							return 
						end
					insert into ORDERS values 
						(@id_orders, @id_payment,
						 @id_orderDetail, @nameDate_orders,
						 @des_orders, @status_orders)
		end;

	execute dbo.Sp_insertOrder 
	'OD004', 'P002', 'ODD04', '01/01/2020', 'huy', '375000'; -- dl Hợp lệ 

	execute dbo.Sp_insertOrder 
	'OD003', 'P2', 'ODD04', '01/01/2020', 'huy', '375000'; -- dl không Hợp lệ (mã hóa đơn đã được sử dụng)

	execute dbo.Sp_insertOrder 
	'OD004', 'P002', 'ODD02', '01/01/2020', 'huy', '375000'; -- dl không Hợp lệ (mã chi tiết hóa đơn đã được sử dụng ) 

	delete ORDERS where id_orders = 'OD004'; 
	select * from ORDERS ;
	drop proc Sp_insertOrder;

	
-- STORED PROCEDURE : 
-- Tạo thủ tục lưu trữ có chức năng thống kê tổng số lượng hàng bán được của một 
-- mặt hàng có mã bất kỳ (mã mặt hàng cần thống kê là tham số của thủ tục) 

CREATE PROCEDURE sp_thongkebanhang(@id_product NVARCHAR(10)) 
	AS 
		select sum(odd.num_orderdetail) as SumProduct from ORDERDETAIL odd     
		where odd.id_product in (select id_product from PRODUCT p 
        where p.id_product = @id_product)  

	execute dbo.sp_thongkebanhang 'PR003' ;
	drop proc sp_thongkebanhang;


 -- Tạo trigger cho bảng chi tiết đơn hàng  
 -- Khi một bản ghi mới được bổ sung vào bảng chi tiết đơn hàng thì giảm số lượng hàng 
 -- hiện có nếu số lượng hàng hiện có lớn hơn hoặc bằng số lượng hàng được 
 -- bán ra. Ngược lại thì huỷ bỏ thao tác bổ sung.

CREATE TRIGGER trg_ordersDetail_insert 
 ON	ORDERDETAIL 
 FOR INSERT 
 AS 
 BEGIN 
	DECLARE @id_product NVARCHAR(10) 
	DECLARE @soluongban INT 
	DECLARE @soluongcon INT
	
	SELECT @id_product = id_product ,@soluongban = num_orderDetail  FROM inserted 
	SELECT @soluongcon =  num_product FROM PRODUCT 	WHERE @id_product = id_product 

	IF @soluongcon >= @soluongban 
		UPDATE PRODUCT SET num_product = num_product - @soluongban 
		WHERE id_product = @id_product 
	ELSE 
		if @soluongcon < @soluongban 
		begin 
			-- print N' Lỗi số lượng hàng! '
			-- return
			ROLLBACK TRANSACTION
		end
 END 

 select * from PRODUCT ; 
 select * from ORDERDETAIL ; 
 insert into ORDERDETAIL (id_orderDetail, id_product, num_orderDetail, price_orderDetail, amount_orderDetail) values
	('ODD06', 'PR001', 5, 195000, 975000);			-- Dữ liệu có thể thêm

 insert into ORDERDETAIL (id_orderDetail, id_product, num_orderDetail, price_orderDetail, amount_orderDetail) values
	('ODD07', 'PR001', 150, 195000, 975000);		-- Dữ liệu lỗi số lượng  

 delete ORDERDETAIL where id_orderDetail = 'ODD06' ;
 update PRODUCT set num_product = 100 where id_product = 'PR001' ;
 drop trigger trg_ordersDetail_insert ;


 -- Tạo trigger trên bảng chi tiết đặt hàng  
 -- Khi vừa cập nhật một chi tiết đơn hàng nào đó thì cập lại 
 -- số lượng sản phẩm trong kho .

 CREATE TRIGGER trg_orderDetail_update_soluong 
	ON ORDERDETAIL after UPDATE 
 AS 
	BEGIN 
		update PRODUCT set num_product = num_product - 
			(select num_orderDetail from inserted where	inserted.id_product = PRODUCT.id_product) +
			(select num_orderDetail from deleted where deleted.id_product = PRODUCT.id_product)
		FROM PRODUCT 
		join deleted on PRODUCT.id_product = deleted.id_product ;
	END 

	update ORDERDETAIL set num_orderDetail = 3 where ORDERDETAIL.id_orderDetail = 'ODD02' ;
	
	drop trigger trg_orderDetail_update_soluong ;
	select * from PRODUCT ;
	select * from ORDERDETAIL ;
	select * from ORDERS ;
	update PRODUCT set num_product = 10 where PRODUCT.id_product = 'PR003' ;
	--
	CREATE TRIGGER trg_DatHang ON tbl_DatHang AFTER INSERT AS 
BEGIN
	UPDATE tbl_KhoHang
	SET SoLuongTon = SoLuongTon - (
		SELECT SoLuongDat
		FROM inserted
		WHERE MaHang = tbl_KhoHang.MaHang
	)
	FROM tbl_KhoHang
	JOIN inserted ON tbl_KhoHang.MaHang = inserted.MaHang
END
GO
