USE master;
GO

-- (1)Database Creation
IF DB_ID(N'IKEADB') IS NOT NULL
BEGIN
    ALTER DATABASE [IKEADB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [IKEADB];
END
GO

CREATE DATABASE [IKEADB];
GO

USE [IKEADB];
GO

-- 1. Staff
CREATE TABLE dbo.Staff (
    Staff_ID            INT IDENTITY(1,1) NOT NULL,
    Staff_FirstName     NVARCHAR(100) NOT NULL,
    Staff_LastName      NVARCHAR(100) NOT NULL,
    PhoneNumber         NVARCHAR(20) NULL,
    Email               NVARCHAR(255) NULL,

    CONSTRAINT PK_Staff PRIMARY KEY (Staff_ID),
    CONSTRAINT UQ_Staff_Email UNIQUE (Email)
);
GO

-- 2. Promotion
CREATE TABLE dbo.Promotion (
    Promotion_ID            INT IDENTITY(1,1) NOT NULL,
    Promotion_description   NVARCHAR(255) NULL,
    Promotion_status        NVARCHAR(50) NULL,

    CONSTRAINT PK_Promotion PRIMARY KEY (Promotion_ID)
);
GO

-- 3. Stock
CREATE TABLE dbo.Stock (
    Stock_ID            INT IDENTITY(1,1) NOT NULL,
    Stock_Status        NVARCHAR(50) NULL,
    Stock_Quantity      INT NOT NULL CONSTRAINT DF_Stock_Quantity DEFAULT 0,

    CONSTRAINT PK_Stock PRIMARY KEY (Stock_ID),
    CONSTRAINT CK_Stock_Quantity CHECK (Stock_Quantity >= 0)
);
GO

-- 4. Order
CREATE TABLE dbo.[Order] (
    Order_ID            INT IDENTITY(1,1) NOT NULL,
    [Date]              DATE NOT NULL,
    [Status]            NVARCHAR(50) NULL,
    TotalPrice          DECIMAL(12,2) NOT NULL CONSTRAINT DF_Order_TotalPrice DEFAULT 0.00,
    Order_Quantity      INT NOT NULL CONSTRAINT DF_Order_Quantity DEFAULT 0,

    CONSTRAINT PK_Order PRIMARY KEY (Order_ID),
    CONSTRAINT CK_Order_TotalPrice CHECK (TotalPrice >= 0),
    CONSTRAINT CK_Order_Quantity CHECK (Order_Quantity >= 0)
);
GO

-- 5. Invoice
CREATE TABLE dbo.Invoice (
    Invoice_ID          INT IDENTITY(1,1) NOT NULL,
    Invoice_Details     NVARCHAR(255) NULL,
    Quantity            INT NOT NULL CONSTRAINT DF_Invoice_Quantity DEFAULT 0,
    Original_Price      DECIMAL(12,2) NOT NULL CONSTRAINT DF_Invoice_OriginalPrice DEFAULT 0.00,
    VAT_Rate            DECIMAL(5,2) NOT NULL CONSTRAINT DF_Invoice_VATRate DEFAULT 0.00,
    TotalAmount         DECIMAL(12,2) NOT NULL CONSTRAINT DF_Invoice_TotalAmount DEFAULT 0.00,
    Order_ID            INT NOT NULL,

    CONSTRAINT PK_Invoice PRIMARY KEY (Invoice_ID),
    CONSTRAINT UQ_Invoice_Order UNIQUE (Order_ID),
    CONSTRAINT CK_Invoice_Quantity CHECK (Quantity >= 0),
    CONSTRAINT CK_Invoice_OriginalPrice CHECK (Original_Price >= 0),
    CONSTRAINT CK_Invoice_VATRate CHECK (VAT_Rate >= 0),
    CONSTRAINT CK_Invoice_TotalAmount CHECK (TotalAmount >= 0),
    CONSTRAINT FK_Invoice_Order
        FOREIGN KEY (Order_ID) REFERENCES dbo.[Order](Order_ID)
);
GO

-- 6. Payment
CREATE TABLE dbo.Payment (
    Payment_ID              INT IDENTITY(1,1) NOT NULL,
    Payment_Status          NVARCHAR(50) NULL,
    Payment_Description     NVARCHAR(255) NULL,
    Invoice_ID              INT NOT NULL,

    CONSTRAINT PK_Payment PRIMARY KEY (Payment_ID),
    CONSTRAINT UQ_Payment_Invoice UNIQUE (Invoice_ID),
    CONSTRAINT FK_Payment_Invoice
        FOREIGN KEY (Invoice_ID) REFERENCES dbo.Invoice(Invoice_ID)
);
GO

-- 7. Payment_Credit_Card
CREATE TABLE dbo.Payment_Credit_Card (
    Payment_ID              INT NOT NULL,
    Credit_Card_number      NVARCHAR(25) NOT NULL,
    Payment_name            NVARCHAR(100) NULL,
    Payment_Description     NVARCHAR(255) NULL,

    CONSTRAINT PK_Payment_Credit_Card PRIMARY KEY (Payment_ID),
    CONSTRAINT UQ_Payment_Credit_Card_Number UNIQUE (Credit_Card_number),
    CONSTRAINT FK_Payment_Credit_Card_Payment
        FOREIGN KEY (Payment_ID) REFERENCES dbo.Payment(Payment_ID)
);
GO

-- 8. Payment_QR
CREATE TABLE dbo.Payment_QR (
    Payment_ID              INT NOT NULL,
    QR_code_ID              NVARCHAR(100) NOT NULL,
    Payment_name            NVARCHAR(100) NULL,
    Payment_Description     NVARCHAR(255) NULL,

    CONSTRAINT PK_Payment_QR PRIMARY KEY (Payment_ID),
    CONSTRAINT UQ_Payment_QR_Code UNIQUE (QR_code_ID),
    CONSTRAINT FK_Payment_QR_Payment
        FOREIGN KEY (Payment_ID) REFERENCES dbo.Payment(Payment_ID)
);
GO

-- 9. Receipt
CREATE TABLE dbo.Receipt (
    Receipt_ID              INT IDENTITY(1,1) NOT NULL,
    Receipt_DateTime        DATETIME2(0) NOT NULL CONSTRAINT DF_Receipt_DateTime DEFAULT SYSDATETIME(),
    Quantity                INT NOT NULL CONSTRAINT DF_Receipt_Quantity DEFAULT 0,
    TotalPrice              DECIMAL(12,2) NOT NULL CONSTRAINT DF_Receipt_TotalPrice DEFAULT 0.00,
    ChangeDue               DECIMAL(12,2) NOT NULL CONSTRAINT DF_Receipt_ChangeDue DEFAULT 0.00,
    TAX_Rate                DECIMAL(5,2) NOT NULL CONSTRAINT DF_Receipt_TAXRate DEFAULT 0.00,
    Payment_ID              INT NOT NULL,

    CONSTRAINT PK_Receipt PRIMARY KEY (Receipt_ID),
    CONSTRAINT UQ_Receipt_Payment UNIQUE (Payment_ID),
    CONSTRAINT CK_Receipt_Quantity CHECK (Quantity >= 0),
    CONSTRAINT CK_Receipt_TotalPrice CHECK (TotalPrice >= 0),
    CONSTRAINT CK_Receipt_ChangeDue CHECK (ChangeDue >= 0),
    CONSTRAINT CK_Receipt_TAXRate CHECK (TAX_Rate >= 0),
    CONSTRAINT FK_Receipt_Payment
        FOREIGN KEY (Payment_ID) REFERENCES dbo.Payment(Payment_ID)
);
GO

-- 10. Customer
CREATE TABLE dbo.Customer (
    Customer_account_ID     INT IDENTITY(1,1) NOT NULL,
    Customer_FirstName      NVARCHAR(100) NOT NULL,
    Customer_LastName       NVARCHAR(100) NOT NULL,
    Email                   NVARCHAR(255) NULL,
    PhoneNumber             NVARCHAR(20) NULL,
    [Address]               NVARCHAR(255) NULL,
    Receipt_ID              INT NULL,

    CONSTRAINT PK_Customer PRIMARY KEY (Customer_account_ID),
    CONSTRAINT FK_Customer_Receipt
        FOREIGN KEY (Receipt_ID) REFERENCES dbo.Receipt(Receipt_ID)
);
GO

-- 11. Membership
CREATE TABLE dbo.Membership (
    Membership_ID           INT IDENTITY(1,1) NOT NULL,
    Membership_tier         NVARCHAR(50) NULL,
    Membership_status       NVARCHAR(50) NULL,
    Customer_account_ID     INT NOT NULL,

    CONSTRAINT PK_Membership PRIMARY KEY (Membership_ID),
    CONSTRAINT UQ_Membership_Customer UNIQUE (Customer_account_ID),
    CONSTRAINT FK_Membership_Customer
        FOREIGN KEY (Customer_account_ID) REFERENCES dbo.Customer(Customer_account_ID)
);
GO

-- 12. Provide
CREATE TABLE dbo.Provide (
    Membership_ID           INT NOT NULL,
    Promotion_ID            INT NOT NULL,
    Discount_Rate           DECIMAL(5,2) NOT NULL CONSTRAINT DF_Provide_DiscountRate DEFAULT 0.00,
    Discount_Limit          DECIMAL(12,2) NOT NULL CONSTRAINT DF_Provide_DiscountLimit DEFAULT 0.00,

    CONSTRAINT PK_Provide PRIMARY KEY (Membership_ID, Promotion_ID),
    CONSTRAINT CK_Provide_DiscountRate CHECK (Discount_Rate >= 0),
    CONSTRAINT CK_Provide_DiscountLimit CHECK (Discount_Limit >= 0),
    CONSTRAINT FK_Provide_Membership
        FOREIGN KEY (Membership_ID) REFERENCES dbo.Membership(Membership_ID),
    CONSTRAINT FK_Provide_Promotion
        FOREIGN KEY (Promotion_ID) REFERENCES dbo.Promotion(Promotion_ID)
);
GO

-- 13. Transaction
CREATE TABLE dbo.[Transaction] (
    Transaction_ID          INT IDENTITY(1,1) NOT NULL,
    Quantity                INT NOT NULL CONSTRAINT DF_Transaction_Quantity DEFAULT 0,
    TotalPrice              DECIMAL(12,2) NOT NULL CONSTRAINT DF_Transaction_TotalPrice DEFAULT 0.00,
    [Status]                NVARCHAR(50) NULL,
    CreatedDate             DATETIME2(0) NOT NULL CONSTRAINT DF_Transaction_CreatedDate DEFAULT SYSDATETIME(),
    Customer_account_ID     INT NOT NULL,
    Payment_ID              INT NOT NULL,

    CONSTRAINT PK_Transaction PRIMARY KEY (Transaction_ID),
    CONSTRAINT CK_Transaction_Quantity CHECK (Quantity >= 0),
    CONSTRAINT CK_Transaction_TotalPrice CHECK (TotalPrice >= 0),
    CONSTRAINT FK_Transaction_Customer
        FOREIGN KEY (Customer_account_ID) REFERENCES dbo.Customer(Customer_account_ID),
    CONSTRAINT FK_Transaction_Payment
        FOREIGN KEY (Payment_ID) REFERENCES dbo.Payment(Payment_ID)
);
GO

-- 14. Place
CREATE TABLE dbo.Place (
    Order_ID                INT NOT NULL,
    Customer_account_ID     INT NOT NULL,
    Place_Date              DATETIME2(0) NOT NULL,
    Place_Status            NVARCHAR(50) NULL,

    CONSTRAINT PK_Place PRIMARY KEY (Order_ID),
    CONSTRAINT FK_Place_Order
        FOREIGN KEY (Order_ID) REFERENCES dbo.[Order](Order_ID),
    CONSTRAINT FK_Place_Customer
        FOREIGN KEY (Customer_account_ID) REFERENCES dbo.Customer(Customer_account_ID)
);
GO

-- 15. ServiceBooking
CREATE TABLE dbo.ServiceBooking (
    Booking_ID              INT IDENTITY(1,1) NOT NULL,
    Booking_Date            DATE NOT NULL,
    Booking_Status          NVARCHAR(50) NULL,
    TimeSlot                NVARCHAR(50) NULL,
    Service_Address         NVARCHAR(255) NULL,
    Order_ID                INT NOT NULL,

    CONSTRAINT PK_ServiceBooking PRIMARY KEY (Booking_ID),
    CONSTRAINT FK_ServiceBooking_Order
        FOREIGN KEY (Order_ID) REFERENCES dbo.[Order](Order_ID)
);
GO

-- 16. Orderline
CREATE TABLE dbo.Orderline (
    Product_line_number     INT IDENTITY(1,1) NOT NULL,
    Amount                  INT NOT NULL CONSTRAINT DF_Orderline_Amount DEFAULT 1,
    Price                   DECIMAL(12,2) NOT NULL CONSTRAINT DF_Orderline_Price DEFAULT 0.00,
    Total_Price             DECIMAL(12,2) NOT NULL CONSTRAINT DF_Orderline_TotalPrice DEFAULT 0.00,
    [Date]                  DATE NULL,
    Order_ID                INT NOT NULL,

    CONSTRAINT PK_Orderline PRIMARY KEY (Product_line_number),
    CONSTRAINT CK_Orderline_Amount CHECK (Amount >= 0),
    CONSTRAINT CK_Orderline_Price CHECK (Price >= 0),
    CONSTRAINT CK_Orderline_TotalPrice CHECK (Total_Price >= 0),
    CONSTRAINT FK_Orderline_Order
        FOREIGN KEY (Order_ID) REFERENCES dbo.[Order](Order_ID)
);
GO

-- 17. Product
CREATE TABLE dbo.Product (
    Product_SerialNumber    NVARCHAR(50) NOT NULL,
    Product_Name            NVARCHAR(150) NOT NULL,
    Product_measurement     NVARCHAR(50) NULL,
    Product_description     NVARCHAR(255) NULL,
    Product_line_number     INT NOT NULL,

    CONSTRAINT PK_Product PRIMARY KEY (Product_SerialNumber),
    CONSTRAINT FK_Product_Orderline
        FOREIGN KEY (Product_line_number) REFERENCES dbo.Orderline(Product_line_number)
);
GO

-- 18. Product_measurements
CREATE TABLE dbo.Product_measurements (
    Measurement_ID          INT IDENTITY(1,1) NOT NULL,
    Product_color           NVARCHAR(50) NULL,
    Product_width           DECIMAL(10,2) NULL,
    Product_height          DECIMAL(10,2) NULL,
    Product_weight          DECIMAL(10,2) NULL,
    Product_depth           DECIMAL(10,2) NULL,
    Product_SerialNumber    NVARCHAR(50) NOT NULL,

    CONSTRAINT PK_Product_measurements PRIMARY KEY (Measurement_ID),
    CONSTRAINT UQ_Product_measurements_Product UNIQUE (Product_SerialNumber),
    CONSTRAINT FK_Product_measurements_Product
        FOREIGN KEY (Product_SerialNumber) REFERENCES dbo.Product(Product_SerialNumber)
);
GO

-- 19. Warranty
CREATE TABLE dbo.Warranty (
    Warranty_ID             INT IDENTITY(1,1) NOT NULL,
    Warranty_Description    NVARCHAR(255) NULL,
    Product_SerialNumber    NVARCHAR(50) NOT NULL,

    CONSTRAINT PK_Warranty PRIMARY KEY (Warranty_ID),
    CONSTRAINT UQ_Warranty_Product UNIQUE (Product_SerialNumber),
    CONSTRAINT FK_Warranty_Product
        FOREIGN KEY (Product_SerialNumber) REFERENCES dbo.Product(Product_SerialNumber)
);
GO

-- 20. Branch
CREATE TABLE dbo.Branch (
    Branch_ID               INT IDENTITY(1,1) NOT NULL,
    Branch_Name             NVARCHAR(150) NOT NULL,
    Branch_Address          NVARCHAR(255) NULL,
    Branch_PhoneNumber      NVARCHAR(20) NULL,
    OperatingHours          NVARCHAR(100) NULL,
    Staff_ID                INT NULL,

    CONSTRAINT PK_Branch PRIMARY KEY (Branch_ID),
    CONSTRAINT FK_Branch_Staff
        FOREIGN KEY (Staff_ID) REFERENCES dbo.Staff(Staff_ID)
);
GO

-- 21. Shipment
CREATE TABLE dbo.Shipment (
    Shipment_ID             INT IDENTITY(1,1) NOT NULL,
    Shipment_type           NVARCHAR(50) NULL,
    Shipment_description    NVARCHAR(255) NULL,
    Shipment_date           DATE NULL,
    Shipment_status         NVARCHAR(50) NULL,
    Staff_ID                INT NOT NULL,
    Product_line_number     INT NOT NULL,

    CONSTRAINT PK_Shipment PRIMARY KEY (Shipment_ID),
    CONSTRAINT FK_Shipment_Staff
        FOREIGN KEY (Staff_ID) REFERENCES dbo.Staff(Staff_ID),
    CONSTRAINT FK_Shipment_Orderline
        FOREIGN KEY (Product_line_number) REFERENCES dbo.Orderline(Product_line_number)
);
GO

-- 22. Tracking
CREATE TABLE dbo.Tracking (
    Tracking_ID             INT IDENTITY(1,1) NOT NULL,
    Tracking_Status         NVARCHAR(50) NULL,
    Tracking_DateTime       DATETIME2(0) NULL,
    Tracking_Number         NVARCHAR(100) NULL,
    Current_Location        NVARCHAR(255) NULL,
    Shipment_ID             INT NOT NULL,

    CONSTRAINT PK_Tracking PRIMARY KEY (Tracking_ID),
    CONSTRAINT FK_Tracking_Shipment
        FOREIGN KEY (Shipment_ID) REFERENCES dbo.Shipment(Shipment_ID)
);
GO

-- 23. Track
CREATE TABLE dbo.Track (
    Product_SerialNumber        NVARCHAR(50) NOT NULL,
    Stock_ID                    INT NOT NULL,
    track_date                  DATETIME2(0) NOT NULL,
    track_updated_movement      NVARCHAR(255) NULL,

    CONSTRAINT PK_Track PRIMARY KEY (Product_SerialNumber, Stock_ID, track_date),
    CONSTRAINT FK_Track_Product
        FOREIGN KEY (Product_SerialNumber) REFERENCES dbo.Product(Product_SerialNumber),
    CONSTRAINT FK_Track_Stock
        FOREIGN KEY (Stock_ID) REFERENCES dbo.Stock(Stock_ID)
);
GO

-- 24. Has
CREATE TABLE dbo.Has (
    Stock_ID                INT NOT NULL,
    Branch_ID               INT NOT NULL,
    updated_status          NVARCHAR(50) NULL,
    updated_date            DATETIME2(0) NOT NULL,
    arrival_date            DATE NULL,

    CONSTRAINT PK_Has PRIMARY KEY (Stock_ID, Branch_ID, updated_date),
    CONSTRAINT FK_Has_Stock
        FOREIGN KEY (Stock_ID) REFERENCES dbo.Stock(Stock_ID),
    CONSTRAINT FK_Has_Branch
        FOREIGN KEY (Branch_ID) REFERENCES dbo.Branch(Branch_ID)
);
GO

-- 25. Return_Request
CREATE TABLE dbo.Return_Request (
    Return_ID               INT IDENTITY(1,1) NOT NULL,
    Return_Date             DATE NOT NULL,
    Return_Reason           NVARCHAR(255) NULL,
    Return_Status           NVARCHAR(50) NULL,
    Approval_Date           DATE NULL,
    Return_Notes            NVARCHAR(500) NULL,
    Customer_account_ID     INT NOT NULL,

    CONSTRAINT PK_Return_Request PRIMARY KEY (Return_ID),
    CONSTRAINT FK_Return_Request_Customer
        FOREIGN KEY (Customer_account_ID) REFERENCES dbo.Customer(Customer_account_ID)
);
GO

-- 26. Refund_Request
CREATE TABLE dbo.Refund_Request (
    Refund_ID               INT IDENTITY(1,1) NOT NULL,
    Refund_Date             DATE NOT NULL,
    Refund_Amount           DECIMAL(12,2) NOT NULL CONSTRAINT DF_Refund_Request_Amount DEFAULT 0.00,
    Refund_Status           NVARCHAR(50) NULL,
    Approval_Date           DATE NULL,
    Refund_Notes            NVARCHAR(500) NULL,
    Return_ID               INT NOT NULL,

    CONSTRAINT PK_Refund_Request PRIMARY KEY (Refund_ID),
    CONSTRAINT CK_Refund_Amount CHECK (Refund_Amount >= 0),
    CONSTRAINT FK_Refund_Request_Return
        FOREIGN KEY (Return_ID) REFERENCES dbo.Return_Request(Return_ID)
);
GO

-- 27. Refund_Payment
CREATE TABLE dbo.Refund_Payment (
    Refund_Payment_ID       INT IDENTITY(1,1) NOT NULL,
    Refund_Payment_Method   NVARCHAR(100) NULL,
    Refund_ID               INT NOT NULL,

    CONSTRAINT PK_Refund_Payment PRIMARY KEY (Refund_Payment_ID),
    CONSTRAINT FK_Refund_Payment_Refund
        FOREIGN KEY (Refund_ID) REFERENCES dbo.Refund_Request(Refund_ID)
);
GO

-- (2)Data Loading
CREATE OR ALTER FUNCTION dbo.fn_Clean (@Value NVARCHAR(4000))
RETURNS NVARCHAR(4000)
AS
BEGIN
    RETURN NULLIF(
        LTRIM(RTRIM(
            REPLACE(
                REPLACE(
                    REPLACE(@Value, NCHAR(65279), N''), -- BOM
                    CHAR(13), N''                       -- CR
                ),
                CHAR(10), N''                           -- LF
            )
        )),
        N''
    );
END;
GO

CREATE OR ALTER FUNCTION dbo.fn_CodeToInt (@Code NVARCHAR(100))
RETURNS INT
AS
BEGIN
    DECLARE @Clean NVARCHAR(100) = dbo.fn_Clean(@Code);
    RETURN TRY_CONVERT(INT, RIGHT(@Clean, 6));
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
    EXEC('CREATE SCHEMA stg');
GO

IF OBJECT_ID('stg.Branch', 'U') IS NOT NULL DROP TABLE stg.Branch;
IF OBJECT_ID('stg.Customer', 'U') IS NOT NULL DROP TABLE stg.Customer;
IF OBJECT_ID('stg.HasTable', 'U') IS NOT NULL DROP TABLE stg.HasTable;
IF OBJECT_ID('stg.Invoice', 'U') IS NOT NULL DROP TABLE stg.Invoice;
IF OBJECT_ID('stg.Membership', 'U') IS NOT NULL DROP TABLE stg.Membership;
IF OBJECT_ID('stg.OrderTable', 'U') IS NOT NULL DROP TABLE stg.OrderTable;
IF OBJECT_ID('stg.Orderline', 'U') IS NOT NULL DROP TABLE stg.Orderline;
IF OBJECT_ID('stg.Payment', 'U') IS NOT NULL DROP TABLE stg.Payment;
IF OBJECT_ID('stg.PaymentCreditCard', 'U') IS NOT NULL DROP TABLE stg.PaymentCreditCard;
IF OBJECT_ID('stg.PaymentQR', 'U') IS NOT NULL DROP TABLE stg.PaymentQR;
IF OBJECT_ID('stg.Place', 'U') IS NOT NULL DROP TABLE stg.Place;
IF OBJECT_ID('stg.ProductMeasurement', 'U') IS NOT NULL DROP TABLE stg.ProductMeasurement;
IF OBJECT_ID('stg.Product', 'U') IS NOT NULL DROP TABLE stg.Product;
IF OBJECT_ID('stg.Promotion', 'U') IS NOT NULL DROP TABLE stg.Promotion;
IF OBJECT_ID('stg.Provide', 'U') IS NOT NULL DROP TABLE stg.Provide;
IF OBJECT_ID('stg.Receipt', 'U') IS NOT NULL DROP TABLE stg.Receipt;
IF OBJECT_ID('stg.RefundPayment', 'U') IS NOT NULL DROP TABLE stg.RefundPayment;
IF OBJECT_ID('stg.RefundRequest', 'U') IS NOT NULL DROP TABLE stg.RefundRequest;
IF OBJECT_ID('stg.ReturnRequest', 'U') IS NOT NULL DROP TABLE stg.ReturnRequest;
IF OBJECT_ID('stg.ServiceBooking', 'U') IS NOT NULL DROP TABLE stg.ServiceBooking;
IF OBJECT_ID('stg.Shipment', 'U') IS NOT NULL DROP TABLE stg.Shipment;
IF OBJECT_ID('stg.Staff', 'U') IS NOT NULL DROP TABLE stg.Staff;
IF OBJECT_ID('stg.Stock', 'U') IS NOT NULL DROP TABLE stg.Stock;
IF OBJECT_ID('stg.Track', 'U') IS NOT NULL DROP TABLE stg.Track;
IF OBJECT_ID('stg.Tracking', 'U') IS NOT NULL DROP TABLE stg.Tracking;
IF OBJECT_ID('stg.TransactionTable', 'U') IS NOT NULL DROP TABLE stg.TransactionTable;
IF OBJECT_ID('stg.Warranty', 'U') IS NOT NULL DROP TABLE stg.Warranty;
GO

-- 1.Staging Branch
CREATE TABLE stg.Branch (
    Branch_ID NVARCHAR(50) NULL,
    Branch_Name NVARCHAR(255) NULL,
    Branch_Address NVARCHAR(500) NULL,
    Branch_PhoneNumber NVARCHAR(50) NULL,
    OperatingHours NVARCHAR(100) NULL,
    Staff_ID NVARCHAR(50) NULL
);
GO

-- 2.Staging Customer
CREATE TABLE stg.Customer (
    Customer_account_ID NVARCHAR(50) NULL,
    Customer_FirstName NVARCHAR(100) NULL,
    Customer_LastName NVARCHAR(100) NULL,
    Email NVARCHAR(255) NULL,
    PhoneNumber NVARCHAR(50) NULL,
    [Address] NVARCHAR(500) NULL,
    Receipt_ID NVARCHAR(50) NULL
);
GO

-- 3.Staging Has
CREATE TABLE stg.HasTable (
    Stock_ID NVARCHAR(50) NULL,
    Branch_ID NVARCHAR(50) NULL,
    updated_status NVARCHAR(50) NULL,
    updated_date NVARCHAR(50) NULL,
    arrival_date NVARCHAR(50) NULL
);
GO

-- 4.Staging Invoice
CREATE TABLE stg.Invoice (
    Invoice_ID NVARCHAR(50) NULL,
    Invoice_Details NVARCHAR(255) NULL,
    Quantity NVARCHAR(50) NULL,
    Original_Price NVARCHAR(50) NULL,
    VAT_Rate NVARCHAR(50) NULL,
    TotalAmount NVARCHAR(50) NULL,
    Order_ID NVARCHAR(50) NULL
);
GO

-- 5.Staging Membership
CREATE TABLE stg.Membership (
    Membership_ID NVARCHAR(50) NULL,
    Membership_tier NVARCHAR(50) NULL,
    Membership_status NVARCHAR(50) NULL,
    Customer_account_ID NVARCHAR(50) NULL
);
GO

-- 6.Staging Order
CREATE TABLE stg.OrderTable (
    Order_ID NVARCHAR(50) NULL,
    [Date] NVARCHAR(50) NULL,
    [Status] NVARCHAR(50) NULL,
    TotalPrice NVARCHAR(50) NULL,
    Order_quantity NVARCHAR(50) NULL
);
GO

-- 7.Staging Orderline
CREATE TABLE stg.Orderline (
    Product_line_number NVARCHAR(50) NULL,
    Amount NVARCHAR(50) NULL,
    Price NVARCHAR(50) NULL,
    Total_Price NVARCHAR(50) NULL,
    [Date] NVARCHAR(50) NULL,
    Order_ID NVARCHAR(50) NULL
);
GO

-- 8.Staging Payment
CREATE TABLE stg.Payment (
    Payment_ID NVARCHAR(50) NULL,
    Payment_Status NVARCHAR(50) NULL,
    Payment_Description NVARCHAR(255) NULL,
    Invoice_ID NVARCHAR(50) NULL
);
GO

-- 9.Staging PaymentCreditCard
CREATE TABLE stg.PaymentCreditCard (
    Payment_ID NVARCHAR(50) NULL,
    Credit_Card_number NVARCHAR(50) NULL,
    Payment_name NVARCHAR(100) NULL,
    Payment_Description NVARCHAR(255) NULL
);
GO

-- 10.Staging PaymemtQR
CREATE TABLE stg.PaymentQR (
    Payment_ID NVARCHAR(50) NULL,
    QR_code_ID NVARCHAR(100) NULL,
    Payment_name NVARCHAR(100) NULL,
    Payment_Description NVARCHAR(255) NULL
);
GO

-- 11.Staging Place
CREATE TABLE stg.Place (
    Customer_account_ID NVARCHAR(50) NULL,
    Order_ID NVARCHAR(50) NULL,
    Place_Date NVARCHAR(50) NULL,
    Place_Status NVARCHAR(50) NULL
);
GO

-- 12.Staging ProductMeasurement
CREATE TABLE stg.ProductMeasurement (
    Measurement_ID NVARCHAR(50) NULL,
    Product_color NVARCHAR(50) NULL,
    Product_width NVARCHAR(50) NULL,
    Product_height NVARCHAR(50) NULL,
    Product_weight NVARCHAR(50) NULL,
    Product_depth NVARCHAR(50) NULL,
    Product_SerialNumber NVARCHAR(50) NULL
);
GO

-- 13.Staging Product
CREATE TABLE stg.Product (
    Product_SerialNumber NVARCHAR(50) NULL,
    Product_Name NVARCHAR(255) NULL,
    Product_measurement NVARCHAR(50) NULL,
    Product_description NVARCHAR(500) NULL,
    Product_line_number NVARCHAR(50) NULL
);
GO

-- 14.Staging Promotion
CREATE TABLE stg.Promotion (
    Promotion_ID NVARCHAR(50) NULL,
    Promotion_description NVARCHAR(255) NULL,
    Promotion_status NVARCHAR(50) NULL
);
GO

-- 15.Staging Provide
CREATE TABLE stg.Provide (
    Promotion_ID NVARCHAR(50) NULL,
    Membership_ID NVARCHAR(50) NULL,
    Discount_Rate NVARCHAR(50) NULL,
    Discount_Limit NVARCHAR(50) NULL
);
GO

-- 16.Staging Receipt
CREATE TABLE stg.Receipt (
    Receipt_ID NVARCHAR(50) NULL,
    Receipt_DateTime NVARCHAR(50) NULL,
    Quantity NVARCHAR(50) NULL,
    TotalPrice NVARCHAR(50) NULL,
    ChangeDue NVARCHAR(50) NULL,
    TAX_Rate NVARCHAR(50) NULL,
    Payment_ID NVARCHAR(50) NULL
);
GO

-- 17.Staging RefundPayment
CREATE TABLE stg.RefundPayment (
    Refund_Payment_ID NVARCHAR(50) NULL,
    Refund_Payment_Method NVARCHAR(100) NULL,
    Refund_ID NVARCHAR(50) NULL
);
GO

-- 18.Staging RefundRequest
CREATE TABLE stg.RefundRequest (
    Refund_ID NVARCHAR(50) NULL,
    Refund_Date NVARCHAR(50) NULL,
    Refund_Amount NVARCHAR(50) NULL,
    Refund_Status NVARCHAR(50) NULL,
    Approval_Date NVARCHAR(50) NULL,
    Refund_Notes NVARCHAR(500) NULL,
    Return_ID NVARCHAR(50) NULL
);
GO

-- 19.Staging ReturnRequest
CREATE TABLE stg.ReturnRequest (
    Return_ID NVARCHAR(50) NULL,
    Return_Date NVARCHAR(50) NULL,
    Return_Reason NVARCHAR(255) NULL,
    Return_Status NVARCHAR(50) NULL,
    Approval_Date NVARCHAR(50) NULL,
    Return_Notes NVARCHAR(500) NULL,
    Customer_account_ID NVARCHAR(50) NULL
);
GO

-- 20.Staging ServiceBooking
CREATE TABLE stg.ServiceBooking (
    Booking_ID NVARCHAR(50) NULL,
    Booking_Date NVARCHAR(50) NULL,
    Booking_Status NVARCHAR(50) NULL,
    TimeSlot NVARCHAR(50) NULL,
    Service_Address NVARCHAR(500) NULL,
    Order_ID NVARCHAR(50) NULL
);
GO

-- 21.Staging Shipment
CREATE TABLE stg.Shipment (
    Shipment_ID NVARCHAR(50) NULL,
    Shipment_type NVARCHAR(50) NULL,
    Shipment_description NVARCHAR(255) NULL,
    Shipment_date NVARCHAR(50) NULL,
    Shipment_status NVARCHAR(50) NULL,
    Staff_ID NVARCHAR(50) NULL,
    Product_line_number NVARCHAR(50) NULL
);
GO

-- 22.Staging Staff
CREATE TABLE stg.Staff (
    Staff_ID NVARCHAR(50) NULL,
    Staff_FirstName NVARCHAR(100) NULL,
    Staff_LastName NVARCHAR(100) NULL,
    PhoneNumber NVARCHAR(50) NULL,
    Email NVARCHAR(255) NULL
);
GO

-- 23.Staging Stock
CREATE TABLE stg.Stock (
    Stock_ID NVARCHAR(50) NULL,
    Stock_Status NVARCHAR(50) NULL,
    Stock_Quantity NVARCHAR(50) NULL
);
GO

-- 24.Staging Track
CREATE TABLE stg.Track (
    Product_SerialNumber NVARCHAR(50) NULL,
    Stock_ID NVARCHAR(50) NULL,
    track_date NVARCHAR(50) NULL,
    track_updated_movement NVARCHAR(255) NULL
);
GO

-- 25.Staging Tracking
CREATE TABLE stg.Tracking (
    Tracking_ID NVARCHAR(50) NULL,
    Tracking_Status NVARCHAR(50) NULL,
    Tracking_DateTime NVARCHAR(50) NULL,
    Tracking_Number NVARCHAR(100) NULL,
    Currect_Location NVARCHAR(255) NULL,
    Shipment_ID NVARCHAR(50) NULL
);
GO

-- 26.Staging TransactionTable
CREATE TABLE stg.TransactionTable (
    Transaction_ID NVARCHAR(50) NULL,
    Quantity NVARCHAR(50) NULL,
    TotalPrice NVARCHAR(50) NULL,
    [Status] NVARCHAR(50) NULL,
    CreatedDate NVARCHAR(50) NULL,
    Payment_ID NVARCHAR(50) NULL,
    Customer_account_ID NVARCHAR(50) NULL
);
GO

-- 27.Staging Warranty
CREATE TABLE stg.Warranty (
    Warranty_ID NVARCHAR(50) NULL,
    Warranty_Description NVARCHAR(255) NULL,
    Product_SerialNumber NVARCHAR(50) NULL
);
GO

TRUNCATE TABLE stg.Branch;
BULK INSERT stg.Branch FROM '/var/opt/mssql/import/Branch.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Customer;
BULK INSERT stg.Customer FROM '/var/opt/mssql/import/Customer.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.HasTable;
BULK INSERT stg.HasTable FROM '/var/opt/mssql/import/Has.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Invoice;
BULK INSERT stg.Invoice FROM '/var/opt/mssql/import/Invoice.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Membership;
BULK INSERT stg.Membership FROM '/var/opt/mssql/import/Membership.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.OrderTable;
BULK INSERT stg.OrderTable FROM '/var/opt/mssql/import/Order.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Orderline;
BULK INSERT stg.Orderline FROM '/var/opt/mssql/import/Orderline.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Payment;
BULK INSERT stg.Payment FROM '/var/opt/mssql/import/Payment.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.PaymentCreditCard;
BULK INSERT stg.PaymentCreditCard FROM '/var/opt/mssql/import/Payment_Credit_Card.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.PaymentQR;
BULK INSERT stg.PaymentQR FROM '/var/opt/mssql/import/Payment_QR.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Place;
BULK INSERT stg.Place FROM '/var/opt/mssql/import/Place.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.ProductMeasurement;
BULK INSERT stg.ProductMeasurement FROM '/var/opt/mssql/import/Product_measurement.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Product;
BULK INSERT stg.Product FROM '/var/opt/mssql/import/Product.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Promotion;
BULK INSERT stg.Promotion FROM '/var/opt/mssql/import/Promotion.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Provide;
BULK INSERT stg.Provide FROM '/var/opt/mssql/import/Provide.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Receipt;
BULK INSERT stg.Receipt FROM '/var/opt/mssql/import/Receipt.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.RefundPayment;
BULK INSERT stg.RefundPayment FROM '/var/opt/mssql/import/Refund_Payment.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.RefundRequest;
BULK INSERT stg.RefundRequest FROM '/var/opt/mssql/import/Refund_Request.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.ReturnRequest;
BULK INSERT stg.ReturnRequest FROM '/var/opt/mssql/import/Return_Request.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.ServiceBooking;
BULK INSERT stg.ServiceBooking FROM '/var/opt/mssql/import/ServiceBooking.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Shipment;
BULK INSERT stg.Shipment FROM '/var/opt/mssql/import/Shipment.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Staff;
BULK INSERT stg.Staff FROM '/var/opt/mssql/import/Staff.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Stock;
BULK INSERT stg.Stock FROM '/var/opt/mssql/import/Stock.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Track;
BULK INSERT stg.Track FROM '/var/opt/mssql/import/Track.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Tracking;
BULK INSERT stg.Tracking FROM '/var/opt/mssql/import/Tracking.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.TransactionTable;
BULK INSERT stg.TransactionTable FROM '/var/opt/mssql/import/Transaction.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

TRUNCATE TABLE stg.Warranty;
BULK INSERT stg.Warranty FROM '/var/opt/mssql/import/Warranty.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDQUOTE = '"');
GO

DELETE FROM dbo.Refund_Payment;
DELETE FROM dbo.Refund_Request;
DELETE FROM dbo.Return_Request;
DELETE FROM dbo.Has;
DELETE FROM dbo.Track;
DELETE FROM dbo.Tracking;
DELETE FROM dbo.Shipment;
DELETE FROM dbo.Branch;
DELETE FROM dbo.Warranty;
DELETE FROM dbo.Product_measurements;
DELETE FROM dbo.Product;
DELETE FROM dbo.Orderline;
DELETE FROM dbo.ServiceBooking;
DELETE FROM dbo.[Transaction];
DELETE FROM dbo.Place;
DELETE FROM dbo.Provide;
DELETE FROM dbo.Membership;
DELETE FROM dbo.Customer;
DELETE FROM dbo.Receipt;
DELETE FROM dbo.Payment_Credit_Card;
DELETE FROM dbo.Payment_QR;
DELETE FROM dbo.Payment;
DELETE FROM dbo.Invoice;
DELETE FROM dbo.[Order];
DELETE FROM dbo.Stock;
DELETE FROM dbo.Promotion;
DELETE FROM dbo.Staff;
GO

DBCC CHECKIDENT ('dbo.Staff', RESEED, 0);
DBCC CHECKIDENT ('dbo.Promotion', RESEED, 0);
DBCC CHECKIDENT ('dbo.Stock', RESEED, 0);
DBCC CHECKIDENT ('dbo.[Order]', RESEED, 0);
DBCC CHECKIDENT ('dbo.Invoice', RESEED, 0);
DBCC CHECKIDENT ('dbo.Payment', RESEED, 0);
DBCC CHECKIDENT ('dbo.Receipt', RESEED, 0);
DBCC CHECKIDENT ('dbo.Customer', RESEED, 0);
DBCC CHECKIDENT ('dbo.Membership', RESEED, 0);
DBCC CHECKIDENT ('dbo.[Transaction]', RESEED, 0);
DBCC CHECKIDENT ('dbo.ServiceBooking', RESEED, 0);
DBCC CHECKIDENT ('dbo.Orderline', RESEED, 0);
DBCC CHECKIDENT ('dbo.Product_measurements', RESEED, 0);
DBCC CHECKIDENT ('dbo.Branch', RESEED, 0);
DBCC CHECKIDENT ('dbo.Shipment', RESEED, 0);
DBCC CHECKIDENT ('dbo.Tracking', RESEED, 0);
DBCC CHECKIDENT ('dbo.Return_Request', RESEED, 0);
DBCC CHECKIDENT ('dbo.Refund_Request', RESEED, 0);
DBCC CHECKIDENT ('dbo.Refund_Payment', RESEED, 0);
DBCC CHECKIDENT ('dbo.Warranty', RESEED, 0);
GO

SET IDENTITY_INSERT dbo.Staff ON;
INSERT INTO dbo.Staff (Staff_ID, Staff_FirstName, Staff_LastName, PhoneNumber, Email)
SELECT dbo.fn_CodeToInt(Staff_ID), dbo.fn_Clean(Staff_FirstName), dbo.fn_Clean(Staff_LastName),
       dbo.fn_Clean(PhoneNumber), dbo.fn_Clean(Email)
FROM stg.Staff;
SET IDENTITY_INSERT dbo.Staff OFF;
GO

SET IDENTITY_INSERT dbo.Promotion ON;
INSERT INTO dbo.Promotion (Promotion_ID, Promotion_description, Promotion_status)
SELECT dbo.fn_CodeToInt(Promotion_ID), dbo.fn_Clean(Promotion_description), dbo.fn_Clean(Promotion_status)
FROM stg.Promotion;
SET IDENTITY_INSERT dbo.Promotion OFF;
GO

SET IDENTITY_INSERT dbo.Stock ON;
INSERT INTO dbo.Stock (Stock_ID, Stock_Status, Stock_Quantity)
SELECT dbo.fn_CodeToInt(Stock_ID), dbo.fn_Clean(Stock_Status),
       TRY_CONVERT(INT, dbo.fn_Clean(Stock_Quantity))
FROM stg.Stock;
SET IDENTITY_INSERT dbo.Stock OFF;
GO

SET IDENTITY_INSERT dbo.[Order] ON;
INSERT INTO dbo.[Order] (Order_ID, [Date], [Status], TotalPrice, Order_Quantity)
SELECT dbo.fn_CodeToInt(Order_ID),
       TRY_CONVERT(DATE, dbo.fn_Clean([Date])),
       dbo.fn_Clean([Status]),
       TRY_CONVERT(DECIMAL(12,2), dbo.fn_Clean(TotalPrice)),
       TRY_CONVERT(INT, dbo.fn_Clean(Order_quantity))
FROM stg.OrderTable;
SET IDENTITY_INSERT dbo.[Order] OFF;
GO

SET IDENTITY_INSERT dbo.Invoice ON;
INSERT INTO dbo.Invoice (Invoice_ID, Invoice_Details, Quantity, Original_Price, VAT_Rate, TotalAmount, Order_ID)
SELECT dbo.fn_CodeToInt(Invoice_ID),
       dbo.fn_Clean(Invoice_Details),
       TRY_CONVERT(INT, dbo.fn_Clean(Quantity)),
       TRY_CONVERT(DECIMAL(12,2), dbo.fn_Clean(Original_Price)),
       TRY_CONVERT(DECIMAL(5,2), dbo.fn_Clean(VAT_Rate)),
       TRY_CONVERT(DECIMAL(12,2), dbo.fn_Clean(TotalAmount)),
       dbo.fn_CodeToInt(Order_ID)
FROM stg.Invoice;
SET IDENTITY_INSERT dbo.Invoice OFF;
GO

SET IDENTITY_INSERT dbo.Payment ON;
INSERT INTO dbo.Payment (Payment_ID, Payment_Status, Payment_Description, Invoice_ID)
SELECT dbo.fn_CodeToInt(Payment_ID),
       dbo.fn_Clean(Payment_Status),
       dbo.fn_Clean(Payment_Description),
       dbo.fn_CodeToInt(Invoice_ID)
FROM stg.Payment;
SET IDENTITY_INSERT dbo.Payment OFF;
GO

INSERT INTO dbo.Payment_Credit_Card (Payment_ID, Credit_Card_number, Payment_name, Payment_Description)
SELECT dbo.fn_CodeToInt(Payment_ID),
       dbo.fn_Clean(Credit_Card_number),
       dbo.fn_Clean(Payment_name),
       dbo.fn_Clean(Payment_Description)
FROM stg.PaymentCreditCard;
GO

INSERT INTO dbo.Payment_QR (Payment_ID, QR_code_ID, Payment_name, Payment_Description)
SELECT dbo.fn_CodeToInt(Payment_ID),
       dbo.fn_Clean(QR_code_ID),
       dbo.fn_Clean(Payment_name),
       dbo.fn_Clean(Payment_Description)
FROM stg.PaymentQR;
GO

SET IDENTITY_INSERT dbo.Receipt ON;
INSERT INTO dbo.Receipt (Receipt_ID, Receipt_DateTime, Quantity, TotalPrice, ChangeDue, TAX_Rate, Payment_ID)
SELECT dbo.fn_CodeToInt(Receipt_ID),
       TRY_CONVERT(DATETIME2(0), dbo.fn_Clean(Receipt_DateTime)),
       TRY_CONVERT(INT, dbo.fn_Clean(Quantity)),
       TRY_CONVERT(DECIMAL(12,2), dbo.fn_Clean(TotalPrice)),
       TRY_CONVERT(DECIMAL(12,2), dbo.fn_Clean(ChangeDue)),
       TRY_CONVERT(DECIMAL(5,2), dbo.fn_Clean(TAX_Rate)),
       dbo.fn_CodeToInt(Payment_ID)
FROM stg.Receipt;
SET IDENTITY_INSERT dbo.Receipt OFF;
GO

SET IDENTITY_INSERT dbo.Customer ON;
INSERT INTO dbo.Customer (Customer_account_ID, Customer_FirstName, Customer_LastName, Email, PhoneNumber, [Address], Receipt_ID)
SELECT dbo.fn_CodeToInt(Customer_account_ID),
       dbo.fn_Clean(Customer_FirstName),
       dbo.fn_Clean(Customer_LastName),
       dbo.fn_Clean(Email),
       dbo.fn_Clean(PhoneNumber),
       dbo.fn_Clean([Address]),
       dbo.fn_CodeToInt(Receipt_ID)
FROM stg.Customer;
SET IDENTITY_INSERT dbo.Customer OFF;
GO

SET IDENTITY_INSERT dbo.Membership ON;
INSERT INTO dbo.Membership (Membership_ID, Membership_tier, Membership_status, Customer_account_ID)
SELECT dbo.fn_CodeToInt(Membership_ID),
       dbo.fn_Clean(Membership_tier),
       dbo.fn_Clean(Membership_status),
       dbo.fn_CodeToInt(Customer_account_ID)
FROM stg.Membership;
SET IDENTITY_INSERT dbo.Membership OFF;
GO

INSERT INTO dbo.Provide (Membership_ID, Promotion_ID, Discount_Rate, Discount_Limit)
SELECT dbo.fn_CodeToInt(Membership_ID),
       dbo.fn_CodeToInt(Promotion_ID),
       TRY_CONVERT(DECIMAL(5,2), dbo.fn_Clean(Discount_Rate)),
       TRY_CONVERT(DECIMAL(12,2), dbo.fn_Clean(Discount_Limit))
FROM stg.Provide;
GO

INSERT INTO dbo.Place (Order_ID, Customer_account_ID, Place_Date, Place_Status)
SELECT dbo.fn_CodeToInt(Order_ID),
       dbo.fn_CodeToInt(Customer_account_ID),
       TRY_CONVERT(DATETIME2(0), dbo.fn_Clean(Place_Date)),
       dbo.fn_Clean(Place_Status)
FROM stg.Place;
GO

SET IDENTITY_INSERT dbo.[Transaction] ON;
INSERT INTO dbo.[Transaction] (Transaction_ID, Quantity, TotalPrice, [Status], CreatedDate, Customer_account_ID, Payment_ID)
SELECT dbo.fn_CodeToInt(Transaction_ID),
       TRY_CONVERT(INT, dbo.fn_Clean(Quantity)),
       TRY_CONVERT(DECIMAL(12,2), dbo.fn_Clean(TotalPrice)),
       dbo.fn_Clean([Status]),
       TRY_CONVERT(DATETIME2(0), dbo.fn_Clean(CreatedDate)),
       dbo.fn_CodeToInt(Customer_account_ID),
       dbo.fn_CodeToInt(Payment_ID)
FROM stg.TransactionTable;
SET IDENTITY_INSERT dbo.[Transaction] OFF;
GO

SET IDENTITY_INSERT dbo.ServiceBooking ON;
INSERT INTO dbo.ServiceBooking (Booking_ID, Booking_Date, Booking_Status, TimeSlot, Service_Address, Order_ID)
SELECT dbo.fn_CodeToInt(Booking_ID),
       TRY_CONVERT(DATE, dbo.fn_Clean(Booking_Date)),
       dbo.fn_Clean(Booking_Status),
       dbo.fn_Clean(TimeSlot),
       dbo.fn_Clean(Service_Address),
       dbo.fn_CodeToInt(Order_ID)
FROM stg.ServiceBooking;
SET IDENTITY_INSERT dbo.ServiceBooking OFF;
GO

SET IDENTITY_INSERT dbo.Orderline ON;
INSERT INTO dbo.Orderline (Product_line_number, Amount, Price, Total_Price, [Date], Order_ID)
SELECT dbo.fn_CodeToInt(Product_line_number),
       TRY_CONVERT(INT, dbo.fn_Clean(Amount)),
       TRY_CONVERT(DECIMAL(12,2), dbo.fn_Clean(Price)),
       TRY_CONVERT(DECIMAL(12,2), dbo.fn_Clean(Total_Price)),
       TRY_CONVERT(DATE, dbo.fn_Clean([Date])),
       dbo.fn_CodeToInt(Order_ID)
FROM stg.Orderline;
SET IDENTITY_INSERT dbo.Orderline OFF;
GO

INSERT INTO dbo.Product (Product_SerialNumber, Product_Name, Product_measurement, Product_description, Product_line_number)
SELECT dbo.fn_Clean(Product_SerialNumber),
       dbo.fn_Clean(Product_Name),
       dbo.fn_Clean(Product_measurement),
       dbo.fn_Clean(Product_description),
       dbo.fn_CodeToInt(Product_line_number)
FROM stg.Product;
GO

SET IDENTITY_INSERT dbo.Product_measurements ON;
INSERT INTO dbo.Product_measurements
(Measurement_ID, Product_color, Product_width, Product_height, Product_weight, Product_depth, Product_SerialNumber)
SELECT dbo.fn_CodeToInt(Measurement_ID),
       dbo.fn_Clean(Product_color),
       TRY_CONVERT(DECIMAL(10,2), dbo.fn_Clean(Product_width)),
       TRY_CONVERT(DECIMAL(10,2), dbo.fn_Clean(Product_height)),
       TRY_CONVERT(DECIMAL(10,2), dbo.fn_Clean(Product_weight)),
       TRY_CONVERT(DECIMAL(10,2), dbo.fn_Clean(Product_depth)),
       dbo.fn_Clean(Product_SerialNumber)
FROM stg.ProductMeasurement;
SET IDENTITY_INSERT dbo.Product_measurements OFF;
GO

SET IDENTITY_INSERT dbo.Warranty ON;
INSERT INTO dbo.Warranty (Warranty_ID, Warranty_Description, Product_SerialNumber)
SELECT dbo.fn_CodeToInt(Warranty_ID),
       dbo.fn_Clean(Warranty_Description),
       dbo.fn_Clean(Product_SerialNumber)
FROM stg.Warranty;
SET IDENTITY_INSERT dbo.Warranty OFF;
GO

SET IDENTITY_INSERT dbo.Branch ON;
INSERT INTO dbo.Branch (Branch_ID, Branch_Name, Branch_Address, Branch_PhoneNumber, OperatingHours, Staff_ID)
SELECT dbo.fn_CodeToInt(Branch_ID),
       dbo.fn_Clean(Branch_Name),
       dbo.fn_Clean(Branch_Address),
       dbo.fn_Clean(Branch_PhoneNumber),
       dbo.fn_Clean(OperatingHours),
       dbo.fn_CodeToInt(Staff_ID)
FROM stg.Branch;
SET IDENTITY_INSERT dbo.Branch OFF;
GO

SET IDENTITY_INSERT dbo.Shipment ON;
INSERT INTO dbo.Shipment (Shipment_ID, Shipment_type, Shipment_description, Shipment_date, Shipment_status, Staff_ID, Product_line_number)
SELECT dbo.fn_CodeToInt(Shipment_ID),
       dbo.fn_Clean(Shipment_type),
       dbo.fn_Clean(Shipment_description),
       TRY_CONVERT(DATE, dbo.fn_Clean(Shipment_date)),
       dbo.fn_Clean(Shipment_status),
       dbo.fn_CodeToInt(Staff_ID),
       dbo.fn_CodeToInt(Product_line_number)
FROM stg.Shipment;
SET IDENTITY_INSERT dbo.Shipment OFF;
GO

SET IDENTITY_INSERT dbo.Tracking ON;
INSERT INTO dbo.Tracking (Tracking_ID, Tracking_Status, Tracking_DateTime, Tracking_Number, Current_Location, Shipment_ID)
SELECT dbo.fn_CodeToInt(Tracking_ID),
       dbo.fn_Clean(Tracking_Status),
       TRY_CONVERT(DATETIME2(0), dbo.fn_Clean(Tracking_DateTime)),
       dbo.fn_Clean(Tracking_Number),
       dbo.fn_Clean(Currect_Location),
       dbo.fn_CodeToInt(Shipment_ID)
FROM stg.Tracking;
SET IDENTITY_INSERT dbo.Tracking OFF;
GO

INSERT INTO dbo.Track (Product_SerialNumber, Stock_ID, track_date, track_updated_movement)
SELECT dbo.fn_Clean(Product_SerialNumber),
       dbo.fn_CodeToInt(Stock_ID),
       TRY_CONVERT(DATETIME2(0), dbo.fn_Clean(track_date)),
       dbo.fn_Clean(track_updated_movement)
FROM stg.Track;
GO

INSERT INTO dbo.Has (Stock_ID, Branch_ID, updated_status, updated_date, arrival_date)
SELECT dbo.fn_CodeToInt(Stock_ID),
       dbo.fn_CodeToInt(Branch_ID),
       dbo.fn_Clean(updated_status),
       TRY_CONVERT(DATETIME2(0), dbo.fn_Clean(updated_date)),
       TRY_CONVERT(DATE, dbo.fn_Clean(arrival_date))
FROM stg.HasTable;
GO

SET IDENTITY_INSERT dbo.Return_Request ON;
INSERT INTO dbo.Return_Request (Return_ID, Return_Date, Return_Reason, Return_Status, Approval_Date, Return_Notes, Customer_account_ID)
SELECT dbo.fn_CodeToInt(Return_ID),
       TRY_CONVERT(DATE, dbo.fn_Clean(Return_Date)),
       dbo.fn_Clean(Return_Reason),
       dbo.fn_Clean(Return_Status),
       TRY_CONVERT(DATE, dbo.fn_Clean(Approval_Date)),
       dbo.fn_Clean(Return_Notes),
       dbo.fn_CodeToInt(Customer_account_ID)
FROM stg.ReturnRequest;
SET IDENTITY_INSERT dbo.Return_Request OFF;
GO

SET IDENTITY_INSERT dbo.Refund_Request ON;
INSERT INTO dbo.Refund_Request (Refund_ID, Refund_Date, Refund_Amount, Refund_Status, Approval_Date, Refund_Notes, Return_ID)
SELECT dbo.fn_CodeToInt(Refund_ID),
       TRY_CONVERT(DATE, dbo.fn_Clean(Refund_Date)),
       TRY_CONVERT(DECIMAL(12,2), dbo.fn_Clean(Refund_Amount)),
       dbo.fn_Clean(Refund_Status),
       TRY_CONVERT(DATE, dbo.fn_Clean(Approval_Date)),
       dbo.fn_Clean(Refund_Notes),
       dbo.fn_CodeToInt(Return_ID)
FROM stg.RefundRequest;
SET IDENTITY_INSERT dbo.Refund_Request OFF;
GO

SET IDENTITY_INSERT dbo.Refund_Payment ON;
INSERT INTO dbo.Refund_Payment (Refund_Payment_ID, Refund_Payment_Method, Refund_ID)
SELECT dbo.fn_CodeToInt(Refund_Payment_ID),
       dbo.fn_Clean(Refund_Payment_Method),
       dbo.fn_CodeToInt(Refund_ID)
FROM stg.RefundPayment;
SET IDENTITY_INSERT dbo.Refund_Payment OFF;
GO

-- (3)Reporting the number of records in each table
SELECT TableName, "RowCount"
FROM (
    SELECT  1 AS Seq, 'Staff' AS TableName, COUNT(*) AS "RowCount" FROM dbo.Staff
    UNION ALL
    SELECT  2, 'Promotion', COUNT(*) FROM dbo.Promotion
    UNION ALL
    SELECT  3, 'Stock', COUNT(*) FROM dbo.Stock
    UNION ALL
    SELECT  4, 'Order', COUNT(*) FROM dbo.[Order]
    UNION ALL
    SELECT  5, 'Invoice', COUNT(*) FROM dbo.Invoice
    UNION ALL
    SELECT  6, 'Payment', COUNT(*) FROM dbo.Payment
    UNION ALL
    SELECT  7, 'Payment_Credit_Card', COUNT(*) FROM dbo.Payment_Credit_Card
    UNION ALL
    SELECT  8, 'Payment_QR', COUNT(*) FROM dbo.Payment_QR
    UNION ALL
    SELECT  9, 'Receipt', COUNT(*) FROM dbo.Receipt
    UNION ALL
    SELECT 10, 'Customer', COUNT(*) FROM dbo.Customer
    UNION ALL
    SELECT 11, 'Membership', COUNT(*) FROM dbo.Membership
    UNION ALL
    SELECT 12, 'Provide', COUNT(*) FROM dbo.Provide
    UNION ALL
    SELECT 13, 'Transaction', COUNT(*) FROM dbo.[Transaction]
    UNION ALL
    SELECT 14, 'Place', COUNT(*) FROM dbo.Place
    UNION ALL
    SELECT 15, 'ServiceBooking', COUNT(*) FROM dbo.ServiceBooking
    UNION ALL
    SELECT 16, 'Orderline', COUNT(*) FROM dbo.Orderline
    UNION ALL
    SELECT 17, 'Product', COUNT(*) FROM dbo.Product
    UNION ALL
    SELECT 18, 'Product_measurements', COUNT(*) FROM dbo.Product_measurements
    UNION ALL
    SELECT 19, 'Warranty', COUNT(*) FROM dbo.Warranty
    UNION ALL
    SELECT 20, 'Branch', COUNT(*) FROM dbo.Branch
    UNION ALL
    SELECT 21, 'Shipment', COUNT(*) FROM dbo.Shipment
    UNION ALL
    SELECT 22, 'Tracking', COUNT(*) FROM dbo.Tracking
    UNION ALL
    SELECT 23, 'Track', COUNT(*) FROM dbo.Track
    UNION ALL
    SELECT 24, 'Has', COUNT(*) FROM dbo.Has
    UNION ALL
    SELECT 25, 'Return_Request', COUNT(*) FROM dbo.Return_Request
    UNION ALL
    SELECT 26, 'Refund_Request', COUNT(*) FROM dbo.Refund_Request
    UNION ALL
    SELECT 27, 'Refund_Payment', COUNT(*) FROM dbo.Refund_Payment
) AS RecordReport
ORDER BY Seq;
GO