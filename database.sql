-- =======================================================================
-- 1. TABLE: LtPaymentMethod
-- Menyimpan data master metode pembayaran (Cash, Debit, Credit).
-- =======================================================================
CREATE TABLE [LtPaymentMethod] (
    [IdPaymentMethod] INT IDENTITY(1, 1) NOT NULL,
    [MethodName] NVARCHAR(50) NOT NULL,
    [Stsrc] BIT NOT NULL,
    [Datein] DATETIME2 NOT NULL,
    [Userin] NVARCHAR(36) NOT NULL,
    [Dateup] DATETIME2 NULL,
    [Userup] NVARCHAR(36) NULL,
    CONSTRAINT [PK_LtPaymentMethod] PRIMARY KEY ([IdPaymentMethod])
);

-- =======================================================================
-- 2. TABLE: MsUser
-- Menyimpan data Admin dan Kasir.
-- =======================================================================
CREATE TABLE [MsUser] (
    [IdUser] NVARCHAR(5) NOT NULL,
    [Username] NVARCHAR(50) NOT NULL,
	[FullName] NVARCHAR(300) NOT NULL,
    [PasswordHash] NVARCHAR(255) NOT NULL,
    [Role] NVARCHAR(20) NOT NULL, -- 'Admin' atau 'Cashier'
    [Stsrc] BIT NOT NULL,
    [Datein] DATETIME2 NOT NULL,
    [Userin] NVARCHAR(36) NOT NULL,
    [Dateup] DATETIME2 NULL,
    [Userup] NVARCHAR(36) NULL,
    CONSTRAINT [PK_MsUser] PRIMARY KEY ([IdUser])
);

-- Index pencarian Username
CREATE UNIQUE INDEX [IX_MsUser_Username] ON [MsUser] ([Username]);

-- =======================================================================
-- 3. TABLE: MsProduct
-- Menyimpan katalog barang.
-- =======================================================================
CREATE TABLE [MsProduct] (
    [IdProduct] NVARCHAR(36) NOT NULL,
    [Name] NVARCHAR(100) NOT NULL,
    [Weight] DECIMAL(10, 2) NOT NULL,
    [Stock] INT NOT NULL,
    [Price] DECIMAL(18, 2) NOT NULL,
    [Discount] DECIMAL(5, 2) NOT NULL DEFAULT 0,
    [Stsrc] BIT NOT NULL,
    [Datein] DATETIME2 NOT NULL,
    [Userin] NVARCHAR(36) NOT NULL,
    [Dateup] DATETIME2 NULL,
    [Userup] NVARCHAR(36) NULL,
    CONSTRAINT [PK_MsProduct] PRIMARY KEY ([IdProduct])
);

-- Index pencarian nama barang saat transaksi
CREATE INDEX [IX_MsProduct_Name] ON [MsProduct] ([Name]);

-- =======================================================================
-- 4. TABLE: TrTransaction
-- Menyimpan data header transaksi beserta format InvoiceNo.
-- =======================================================================
CREATE TABLE [TrTransaction] (
    [IdTransaction] NVARCHAR(36) NOT NULL, -- new guid()
    [InvoiceNo] NVARCHAR(20) NOT NULL,  -- format insert digenerate dari FE (Iduser + ddmmyy + 3 running number transaction) 
    [TransactionDate] DATETIME2 NOT NULL,
    [IdUser] NVARCHAR(5) NOT NULL,
    [IdPaymentMethod] INT NOT NULL, -- FK ke LtPaymentMethod
    [TotalPrice] DECIMAL(18, 2) NOT NULL,
    [Stsrc] BIT NOT NULL,
    [Datein] DATETIME2 NOT NULL,
    [Userin] NVARCHAR(36) NOT NULL,
    [Dateup] DATETIME2 NULL,
    [Userup] NVARCHAR(36) NULL,
    CONSTRAINT [PK_TrTransaction] PRIMARY KEY ([IdTransaction]),
    CONSTRAINT [FK_TrTransaction_MsUser_IdUser] FOREIGN KEY ([IdUser]) REFERENCES [MsUser] ([IdUser]) ON DELETE NO ACTION,
    CONSTRAINT [FK_TrTransaction_LtPaymentMethod_IdPaymentMethod] FOREIGN KEY ([IdPaymentMethod]) REFERENCES [LtPaymentMethod] ([IdPaymentMethod]) ON DELETE NO ACTION
);

-- Index untuk validasi nomor invoice dan performa history (filter tanggal & user)
CREATE UNIQUE INDEX [IX_TrTransaction_InvoiceNo] ON [TrTransaction] ([InvoiceNo]);
CREATE INDEX [IX_TrTransaction_TransactionDate] ON [TrTransaction] ([TransactionDate]);
CREATE INDEX [IX_TrTransaction_IdUser] ON [TrTransaction] ([IdUser]);
CREATE INDEX [IX_TrTransaction_IdPaymentMethod] ON [TrTransaction] ([IdPaymentMethod]);

-- =======================================================================
-- 5. TABLE: TrTransactionDetail
-- Menyimpan data keranjang / rincian item per transaksi.
-- =======================================================================
CREATE TABLE [TrTransactionDetail] (
    [IdTransactionDetail] NVARCHAR(36) NOT NULL, -- new guid()
    [IdTransaction] NVARCHAR(36) NOT NULL, -- new guid()
    [IdProduct] NVARCHAR(36) NOT NULL, 
    [Qty] INT NOT NULL,
    [Price] DECIMAL(18, 2) NOT NULL,
    [Discount] DECIMAL(5, 2) NOT NULL DEFAULT 0,
    [SubTotal] DECIMAL(18, 2) NOT NULL,
    [Stsrc] BIT NOT NULL,
    [Datein] DATETIME2 NOT NULL,
    [Userin] NVARCHAR(36) NOT NULL,
    [Dateup] DATETIME2 NULL,
    [Userup] NVARCHAR(36) NULL,
    CONSTRAINT [PK_TrTransactionDetail] PRIMARY KEY ([IdTransactionDetail]),
    CONSTRAINT [FK_TrTransactionDetail_TrTransaction_IdTransaction] FOREIGN KEY ([IdTransaction]) REFERENCES [TrTransaction] ([IdTransaction]) ON DELETE CASCADE,
    CONSTRAINT [FK_TrTransactionDetail_MsProduct_IdProduct] FOREIGN KEY ([IdProduct]) REFERENCES [MsProduct] ([IdProduct]) ON DELETE NO ACTION
);

-- Index untuk performa join tabel rincian transaksi
CREATE INDEX [IX_TrTransactionDetail_IdTransaction] ON [TrTransactionDetail] ([IdTransaction]);
CREATE INDEX [IX_TrTransactionDetail_IdProduct] ON [TrTransactionDetail] ([IdProduct]);


/*Insert Data*/
INSERT INTO [LtPaymentMethod] ([MethodName], [Stsrc], [Datein], [Userin]) 
VALUES 
    ('Cash', 1, GETDATE(), 'SYSTEM'),
    ('Debit', 1, GETDATE(), 'SYSTEM'),
    ('Credit', 1, GETDATE(), 'SYSTEM');

INSERT INTO [MsProduct] 
([IdProduct], [Name], [Weight], [Stock], [Price], [Discount], [Stsrc], [Datein], [Userin], [Dateup], [Userup])
VALUES
-- ==========================================
-- KATEGORI 1: MIE INSTAN & PASTA (40 Data)
-- ==========================================
(NEWID(), 'Indomie Mi Goreng Spesial', 85, 150, 3100, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomie Mi Goreng Rendang', 91, 100, 3200, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomie Mi Goreng Pedas', 79, 120, 3100, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomie Mi Goreng Ayam Geprek', 85, 80, 3200, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomie Mi Goreng Aceh', 90, 85, 3200, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomie Kuah Ayam Bawang', 69, 150, 3000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomie Kuah Soto Mie', 70, 140, 3000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomie Kuah Kari Ayam', 72, 130, 3100, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomie Kuah Soto Spesial', 75, 100, 3100, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomie Kuah Kaldu Ayam', 70, 90, 3000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomie Seblak Hot Jeletot', 75, 60, 3200, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mie Sedaap Goreng', 90, 150, 3100, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mie Sedaap Goreng Korean Spicy', 87, 100, 3200, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mie Sedaap Goreng Salero Padang', 86, 70, 3200, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mie Sedaap Kuah Soto', 75, 140, 3000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mie Sedaap Kuah Kari Spesial', 75, 100, 3100, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mie Sedaap Kuah Ayam Bawang', 70, 110, 3000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mie Sedaap Kuah White Curry', 81, 60, 3200, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mie Sedaap Cup Goreng', 85, 50, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mie Sedaap Cup Soto', 81, 50, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mie Sedaap Cup Baso Bledek', 81, 40, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pop Mie Goreng Spesial', 80, 80, 5600, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pop Mie Kuah Ayam', 75, 90, 5600, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pop Mie Kuah Baso', 75, 90, 5600, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pop Mie Kuah Kari Ayam', 75, 80, 5600, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pop Mie Kuah Soto Ayam', 75, 85, 5600, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pop Mie Dower Pedas', 75, 60, 5800, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pop Mie Gledek Pedas', 75, 60, 5800, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sarimi Isi 2 Goreng Kecap', 126, 70, 4200, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sarimi Isi 2 Kuah Soto', 115, 60, 4000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sarimi Isi 2 Kuah Kari Ayam', 115, 60, 4000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Supermi Nutrimi Rasa Steak Ayam', 80, 40, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Lemonilo Mie Goreng', 80, 50, 7500, 5, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Lemonilo Mie Kuah Ayam Bawang', 70, 40, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Lemonilo Mie Kuah Kari Ayam', 70, 40, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Gaga 100 Extra Pedas Jalapeno', 85, 50, 3500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Gaga 100 Extra Pedas Lada Hitam', 85, 40, 3500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Samyang Hot Chicken Ramen', 140, 30, 22000, 10, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Samyang Carbonara Ramen', 130, 35, 23500, 5, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Samyang Cheese Ramen', 140, 20, 23500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),

-- ==========================================
-- KATEGORI 2: AIR MINERAL & MINUMAN (50 Data)
-- ==========================================
(NEWID(), 'Aqua Air Mineral 330ml', 330, 150, 2500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Aqua Air Mineral 600ml', 600, 200, 3500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Aqua Air Mineral 1500ml', 1500, 100, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Le Minerale Air Mineral 600ml', 600, 180, 3500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Le Minerale Air Mineral 1500ml', 1500, 90, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pristine 8.6+ Water 400ml', 400, 80, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pristine 8.6+ Water 600ml', 600, 80, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Vit Air Mineral 600ml', 600, 120, 3000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Vit Air Mineral 1500ml', 1500, 80, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nestle Pure Life 600ml', 600, 100, 3500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Teh Pucuk Harum 350ml', 350, 150, 4000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Teh Pucuk Harum Less Sugar 350ml', 350, 80, 4000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Teh Botol Sosro Original 350ml', 350, 120, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Teh Botol Sosro Less Sugar 350ml', 350, 70, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Teh Botol Sosro Kotak 250ml', 250, 100, 3500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Frestea Apple 350ml', 350, 80, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Frestea Jasmine 350ml', 350, 90, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nu Green Tea Honey 330ml', 330, 85, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nu Green Tea Original 330ml', 330, 75, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Ichitan Thai Milk Tea 310ml', 310, 60, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Ichitan Brown Sugar Milk 310ml', 310, 60, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kopiko 78C Coffee Latte 240ml', 240, 80, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Golda Coffee Dolce Latte 200ml', 200, 100, 3500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kopi Kenangan Mantancino 220ml', 220, 50, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kopi Kenangan Black Aren 220ml', 220, 60, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nescafe Original 240ml', 240, 70, 7000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nescafe Mocha 240ml', 240, 70, 7000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Good Day Mocacinno 250ml', 250, 90, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Good Day Tiramisu 250ml', 250, 80, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pocari Sweat 330ml', 330, 120, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pocari Sweat 500ml', 500, 100, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mizone Active 500ml', 500, 80, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Isoplus 350ml', 350, 90, 4000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Coca Cola 390ml', 390, 100, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Coca Cola 1500ml', 1500, 50, 15500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sprite 390ml', 390, 90, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Fanta Strawberry 390ml', 390, 80, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Tebs Sparkling 330ml', 330, 60, 6000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Floridina Orange 350ml', 350, 110, 3500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Minute Maid Pulpy Orange 300ml', 300, 80, 6000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Buavita Apple 250ml', 250, 70, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Buavita Guava 250ml', 250, 70, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Buavita Mango 250ml', 250, 60, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Fruit Tea Apel 350ml', 350, 90, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Fruit Tea Blackcurrant 350ml', 350, 80, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'You C1000 Lemon 140ml', 140, 100, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'You C1000 Orange 140ml', 140, 100, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Adem Sari Ching Ku 320ml', 320, 60, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Larutan Cap Badak Original 330ml', 330, 70, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Larutan Cap Badak Leci 330ml', 330, 60, 6000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),

-- ==========================================
-- KATEGORI 3: SUSU & YOGHURT (40 Data)
-- ==========================================
(NEWID(), 'Susu Ultra Milk Coklat 250ml', 250, 150, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Susu Ultra Milk Full Cream 250ml', 250, 140, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Susu Ultra Milk Strawberry 250ml', 250, 100, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Susu Ultra Milk Moka 250ml', 250, 80, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Susu Ultra Milk Coklat 1000ml', 1000, 50, 19500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Susu Ultra Milk Full Cream 1000ml', 1000, 60, 19500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Bear Brand Susu Steril 189ml', 189, 120, 10500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomilk Coklat 250ml', 250, 100, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomilk Full Cream 250ml', 250, 90, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomilk Coklat 1000ml', 1000, 40, 18500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Frisian Flag Coklat 225ml', 225, 110, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Frisian Flag Full Cream 225ml', 225, 90, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Greenfields Full Cream 1000ml', 1000, 30, 24500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Greenfields Choco Malt 1000ml', 1000, 25, 25500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Cimory Yoghurt Drink Blueberry 250ml', 250, 60, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Cimory Yoghurt Drink Strawberry 250ml', 250, 60, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Cimory Yoghurt Drink Mixed Berry 250ml', 250, 50, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Cimory Squeeze Original 120g', 120, 80, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Cimory Squeeze Strawberry 120g', 120, 80, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Cimory Squeeze Peach 120g', 120, 70, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Yakult Minuman Probiotik 5x65ml', 325, 80, 10500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Yakult Light 5x65ml', 325, 50, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Milo Susu UHT Kotak 180ml', 180, 100, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Milo Susu UHT Kotak 115ml', 115, 80, 3500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Chil Go Coklat 130ml', 130, 50, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Chil Go Vanilla 130ml', 130, 45, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Vidoran Xmart Coklat 115ml', 115, 60, 3000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Dancow Fortigro Coklat 200ml', 200, 70, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Dancow Fortigro Strawberry 200ml', 200, 60, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Frisian Flag SKM Putih 370g', 370, 80, 12500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Frisian Flag SKM Coklat 370g', 370, 75, 12500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomilk SKM Putih 370g', 370, 70, 12000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indomilk SKM Coklat 370g', 370, 60, 12000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Bebelac 3 Madu 400g', 400, 20, 65000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Bebelac 3 Vanilla 400g', 400, 20, 65000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Bebelac 4 Madu 400g', 400, 15, 62000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'SGM Eksplor 1+ Madu 400g', 400, 30, 38000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'SGM Eksplor 1+ Vanilla 400g', 400, 30, 38000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Dancow 1+ Madu 400g', 400, 25, 52000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Dancow 1+ Vanilla 400g', 400, 25, 52000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),

-- ==========================================
-- KATEGORI 4: SNACK, KERIPIK & KACANG (40 Data)
-- ==========================================
(NEWID(), 'Chitato Sapi Panggang 68g', 68, 100, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Chitato Ayam Bumbu 68g', 68, 80, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Chitato Keju Supreme 68g', 68, 70, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Chitato Lite Nori Seaweed 68g', 68, 90, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Chitato Lite Sapi Panggang 68g', 68, 80, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Lays Rasa Rumput Laut 68g', 68, 85, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Lays Rasa Salmon Teriyaki 68g', 68, 60, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Taro Net Seaweed 65g', 65, 110, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Taro Net Potato BBQ 65g', 65, 100, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Qtela Singkong Balado 60g', 60, 120, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Qtela Singkong BBQ 60g', 60, 100, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Qtela Singkong Original 60g', 60, 90, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kusuka Keripik Singkong Balado 60g', 60, 80, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kusuka Keripik Singkong BBQ 60g', 60, 70, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Potabee Beef BBQ 68g', 68, 80, 10500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Potabee Seaweed 68g', 68, 85, 10500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Japota Honey Butter 68g', 68, 70, 11000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Japota Umami Japanese Seaweed 68g', 68, 75, 11000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Cheetos Jagung Bakar 75g', 75, 80, 9000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Cheetos Twist Keju 75g', 75, 85, 9000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Chiki Balls Keju 55g', 55, 100, 7000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Chiki Balls Coklat 55g', 55, 90, 7000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Happy Tos Merah 160g', 160, 70, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Happy Tos Hijau 160g', 160, 60, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mister Potato Crisps BBQ 85g', 85, 50, 15500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mister Potato Crisps Original 85g', 85, 45, 15500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pringles Original 107g', 107, 40, 22500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pringles Sour Cream 107g', 107, 45, 22500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kacang Garuda Rosta 100g', 100, 80, 10000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kacang Garuda Kulit 200g', 200, 60, 18000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kacang Dua Kelinci Kulit 200g', 200, 65, 17500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kacang Dua Kelinci Sukro 100g', 100, 90, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kacang Dua Kelinci Tic Tac 90g', 90, 100, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kuaci Rebo Original 150g', 150, 70, 15000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kuaci Rebo Green Tea 150g', 150, 60, 15000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kuaci Rebo Milk 150g', 150, 65, 15000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Oishi Sponge Crunch Choco 120g', 120, 60, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Oishi Sponge Crunch Strawberry 120g', 120, 50, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Oishi Pillows Choco 110g', 110, 70, 12500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Oishi Popcorn Caramel 100g', 100, 60, 14500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),

-- ==========================================
-- KATEGORI 5: BISKUIT, WAFER, COKELAT & ROTI (45 Data)
-- ==========================================
(NEWID(), 'Oreo Vanilla 133g', 133, 100, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Oreo Chocolate 133g', 133, 90, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Oreo Ice Cream Blueberry 133g', 133, 70, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Oreo Strawberry 133g', 133, 75, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Slai O Lai Strawberry 128g', 128, 80, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Slai O Lai Blueberry 128g', 128, 75, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Roma Kelapa 300g', 300, 80, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Roma Sari Gandum 115g', 115, 90, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Roma Sari Gandum Coklat 115g', 115, 85, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Roma Malkist Crackers 135g', 135, 100, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Roma Malkist Coklat 135g', 135, 90, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Roma Malkist Keju Manis 135g', 135, 85, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Biskuat Coklat 140g', 140, 80, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Ritz Crackers Keju 118g', 118, 60, 10500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Good Time Classic Chocochip 72g', 72, 100, 8000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Good Time Double Choc 72g', 72, 90, 8000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Tango Wafer Coklat 130g', 130, 95, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Tango Wafer Vanilla 130g', 130, 85, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Tango Wafer Keju 130g', 130, 70, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nabati Wafer Keju 122g', 122, 100, 8000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nabati Wafer Coklat 122g', 122, 95, 8000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Biskies Sandwich Coklat 108g', 108, 60, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Tim Tam Coklat 81g', 81, 70, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Tim Tam Vanilla 81g', 81, 65, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Beng Beng Wafer Coklat 20g', 20, 200, 2500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Beng Beng Share It 95g', 95, 60, 14500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Top Wafer Coklat 16g', 16, 180, 2000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Silverqueen Almond 62g', 62, 80, 17500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Silverqueen Cashew 62g', 62, 90, 17500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Silverqueen Chunky Bar 30g', 30, 100, 10500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Silverqueen Chunky Bar 100g', 100, 50, 25500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Cadbury Dairy Milk 62g', 62, 70, 16500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Cadbury Cashew Nut 62g', 62, 65, 16500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Delfi Dairy Milk 50g', 50, 50, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kinder Joy Boys 20g', 20, 80, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kinder Joy Girls 20g', 20, 80, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Yupi Gummy Bears 40g', 40, 150, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Yupi Strawberry Kiss 40g', 40, 140, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Yupi Neon Stix 40g', 40, 100, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sari Roti Tawar Spesial', 400, 40, 17000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sari Roti Tawar Gandum', 400, 30, 20000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sari Roti Sobek Coklat Keju', 200, 40, 18000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Aoka Roti Panggang Susu Vanilla', 65, 100, 3000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Aoka Roti Panggang Coklat', 65, 110, 3000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Aoka Roti Panggang Blueberry', 65, 90, 3000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),

-- ==========================================
-- KATEGORI 6: KOPI BUBUK, TEH & SEDUH (25 Data)
-- ==========================================
(NEWID(), 'Kapal Api Special Mix 10x24g', 240, 60, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kapal Api Kopi Bubuk Special 165g', 165, 50, 15500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kapal Api Less Sugar 10x20g', 200, 40, 12500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Luwak White Koffie Original 10x20g', 200, 70, 14500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Luwak White Koffie Tarik 10x20g', 200, 50, 14500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Good Day Mocacinno Sachet 10x20g', 200, 80, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Good Day Chococinno Sachet 10x20g', 200, 75, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Good Day Vanilla Latte 10x20g', 200, 70, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Torabika Susu Full Cream 10x28g', 280, 50, 14500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Torabika Gilus Mix 10x23g', 230, 60, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nescafe Classic Kopi Bubuk 50g', 50, 40, 17500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nescafe 3in1 Original 10x17g', 170, 60, 15500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'ABC Kopi Susu 10x31g', 310, 60, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sariwangi Teh Asli 25s', 45, 90, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sariwangi Teh Melati 25s', 45, 70, 7000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sariwangi Teh Hijau 25s', 45, 50, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Teh Cap Botol Celup 25s', 45, 80, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Teh Cap Botol Melati 25s', 45, 70, 8000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sosro Teh Celup Black Tea 30s', 60, 60, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Tong Tji Teh Celup Jasmine 25s', 50, 70, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Energen Coklat 10x29g', 290, 80, 17500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Energen Vanilla 10x29g', 290, 70, 17500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Energen Kacang Hijau 10x29g', 290, 60, 17500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Milo Sachet 3in1 10x35g', 350, 80, 32500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Chocolatos Drink Coklat 10x28g', 280, 60, 18500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),

-- ==========================================
-- KATEGORI 7: SABUN MANDI, SHAMPOO, ODOL (35 Data)
-- ==========================================
(NEWID(), 'Lifebuoy Sabun Batang Total 10 110g', 110, 150, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Lifebuoy Sabun Batang Lemon 110g', 110, 100, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Lifebuoy Sabun Cair Total 10 Refill 450ml', 450, 80, 24500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Lifebuoy Sabun Cair Lemon Refill 450ml', 450, 70, 24500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nuvo Sabun Batang Merah 110g', 110, 120, 3500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nuvo Sabun Batang Biru 110g', 110, 120, 3500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nuvo Sabun Cair Merah Refill 450ml', 450, 70, 19500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Dettol Sabun Cair Original Refill 410ml', 410, 60, 31500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Dettol Sabun Batang Original 100g', 100, 100, 7500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Biore Body Foam Guard Refill 450ml', 450, 60, 26500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Biore Body Foam Relaxing Refill 450ml', 450, 60, 26500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Lux Body Wash Velvet Jasmine Refill 450ml', 450, 70, 25500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Shinzui Body Wash Kirei Refill 420ml', 420, 80, 23500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Shinzui Body Wash Matsu Refill 420ml', 420, 70, 23500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Clear Shampoo Ice Menthol 160ml', 160, 60, 27500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Clear Shampoo Complete Soft Care 160ml', 160, 50, 27500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sunsilk Shampoo Black Shine 170ml', 170, 70, 24500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sunsilk Shampoo Soft & Smooth 170ml', 170, 70, 24500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pantene Shampoo Anti Dandruff 160ml', 160, 60, 26500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pantene Shampoo Hair Fall Control 160ml', 160, 60, 26500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Head & Shoulders Cool Menthol 160ml', 160, 50, 29500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Dove Shampoo Damage Therapy 160ml', 160, 45, 25500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Zinc Shampoo Anti Ketombe 170ml', 170, 60, 21500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pepsodent Pasta Gigi White 190g', 190, 120, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pepsodent Action 123 190g', 190, 90, 14500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pepsodent Sensitive Expert 100g', 100, 50, 28500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Ciptadent Pasta Gigi Fresh Mint 190g', 190, 100, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Ciptadent Pasta Gigi Cool Mint 190g', 190, 90, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Close Up Pasta Gigi Menthol 160g', 160, 80, 17500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sensodyne Pasta Gigi Fresh Mint 100g', 100, 40, 32500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Listerine Cool Mint 250ml', 250, 50, 23500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Listerine Zero 250ml', 250, 45, 23500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Pepsodent Sikat Gigi Double Care Soft', 30, 80, 12500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Formula Sikat Gigi Diamond', 30, 90, 10500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Ciptadent Sikat Gigi Classic', 30, 100, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),

-- ==========================================
-- KATEGORI 8: PERSONAL CARE & KECANTIKAN (25 Data)
-- ==========================================
(NEWID(), 'Rexona Men Roll On Ice Cool 50ml', 50, 60, 18500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Rexona Men Roll On Adventure 50ml', 50, 50, 18500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Rexona Women Roll On Free Spirit 50ml', 50, 70, 18500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Rexona Women Roll On Powder Dry 50ml', 50, 65, 18500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nivea Men Roll On Black & White 50ml', 50, 40, 21500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nivea Women Roll On Extra Whitening 50ml', 50, 45, 21500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Gatsby Splash Cologne Musky 175ml', 175, 40, 22500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Bellagio Homme Pomade 80g', 80, 35, 32500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Gatsby Styling Pomade Supreme Hold 75g', 75, 50, 28500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Fair & Lovely Krim Pencerah Harian 50g', 50, 60, 25500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Wardah Perfect Bright Moisturizer 20ml', 20, 50, 26500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Garnier Men Facial Wash Acno Fight 100ml', 100, 45, 31500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Garnier Men Facial Wash Wasabi 100ml', 100, 40, 31500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Biore Men Facial Wash Cool 100g', 100, 50, 28500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Ponds Facial Foam Pure White 100g', 100, 55, 32500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Marina Hand Body UV White 200ml', 200, 70, 12500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Citra Hand Body Pearly White 230ml', 230, 60, 22500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Vaseline Body Lotion Aloe Soothe 200ml', 200, 50, 28500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Nivea Body Lotion Extra White 200ml', 200, 45, 31500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Laurier Relax Night 30cm 16s', 150, 60, 18500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Laurier Active Day Super Maxi 20s', 120, 70, 15500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Charm Body Fit Night 29cm 10s', 100, 50, 14500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Charm Cooling Fresh Day 23cm 20s', 120, 60, 22500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Softex Celana Menstruasi All Size 2s', 50, 40, 20500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mitu Baby Wipes Antiseptic 50s', 200, 80, 16500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),

-- ==========================================
-- KATEGORI 9: KEBERSIHAN RUMAH TANGGA (30 Data)
-- ==========================================
(NEWID(), 'Rinso Anti Noda Bubuk 770g', 770, 70, 24500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Rinso Molto Deterjen Bubuk 770g', 770, 65, 25500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Rinso Cair Rose Fresh Refill 700ml', 700, 80, 22500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Daia Deterjen Bunga 850g', 850, 90, 18500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Daia Deterjen Lemon 850g', 850, 85, 18500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Soklin Liquid Softergent Refill 750ml', 750, 80, 20500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Attack Jaz1 Deterjen Bubuk 800g', 800, 70, 19500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Attack Plus Softener Bubuk 800g', 800, 60, 23500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Downy Mystique Refill 720ml', 720, 60, 32500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Downy Sunrise Fresh Refill 720ml', 720, 70, 30500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Molto All in One Blue Refill 720ml', 720, 65, 28500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Molto Eau de Parfum Pink Refill 720ml', 720, 60, 29500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sunlight Jeruk Nipis Refill 650ml', 650, 150, 15500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sunlight Strawberry Refill 650ml', 650, 90, 15500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mama Lemon Ekstrak Lemon Refill 680ml', 680, 120, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mama Lemon Ekstrak Jeruk Nipis 680ml', 680, 110, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Wipol Karbol Wangi Pine Refill 750ml', 750, 80, 18500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Wipol Karbol Lemon Refill 750ml', 750, 70, 18500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Super Pell Pembersih Lantai Apple 770ml', 770, 90, 16500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Super Pell Pembersih Lantai Lemon 770ml', 770, 85, 16500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Vixal Pembersih Porselen Biru 780ml', 780, 70, 19500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Vixal Pembersih Porselen Hijau 780ml', 780, 65, 19500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Porstex Pembersih Keramik 1000ml', 1000, 50, 21500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Baygon Aerosol Nyamuk Kuning 600ml', 600, 60, 38500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Hit Aerosol Nyamuk Lily 600ml', 600, 70, 36500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Hit Aerosol Nyamuk Orange 600ml', 600, 65, 36500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Bagus Kapur Ajaib 2s', 20, 150, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Stella Air Freshener Orange 400ml', 400, 40, 22500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Glade Air Freshener Lavender 400ml', 400, 45, 23500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Swallow Kamper Toilet 5s', 150, 80, 15500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),

-- ==========================================
-- KATEGORI 10: SEMBAKO, BUMBU & DAPUR (40 Data)
-- ==========================================
(NEWID(), 'Bimoli Minyak Goreng Pouch 2L', 2000, 100, 38500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Bimoli Minyak Goreng Pouch 1L', 1000, 120, 19500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sania Minyak Goreng Pouch 2L', 2000, 150, 36500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sania Minyak Goreng Pouch 1L', 1000, 110, 18500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sunco Minyak Goreng Pouch 2L', 2000, 90, 39500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Tropical Minyak Goreng Botol 2L', 2000, 70, 40500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Filma Minyak Goreng Pouch 2L', 2000, 80, 37500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Gulaku Gula Pasir Premium 1Kg', 1000, 200, 16500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Gulaku Gula Pasir Kuning 1Kg', 1000, 150, 16000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Rose Brand Gula Pasir 1Kg', 1000, 180, 16000, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kunci Biru Tepung Terigu 1Kg', 1000, 100, 12500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Segitiga Biru Tepung Terigu 1Kg', 1000, 120, 13500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Cakra Kembar Tepung Terigu 1Kg', 1000, 90, 14500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sasa Tepung Bumbu Serbaguna 225g', 225, 150, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kobe Tepung Bumbu Kentucky 210g', 210, 130, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Bango Kecap Manis Refill 520ml', 520, 100, 24500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Bango Kecap Manis Refill 220ml', 220, 110, 11500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'ABC Kecap Manis Refill 520ml', 520, 120, 21500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'ABC Kecap Manis Refill 225ml', 225, 130, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sedaap Kecap Manis Refill 520ml', 520, 90, 20500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'ABC Saus Sambal Asli 340ml', 340, 80, 16500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'ABC Saus Sambal Extra Pedas 340ml', 340, 85, 17500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indofood Saus Sambal Pedas 340ml', 340, 70, 15500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Indofood Saus Tomat 340ml', 340, 60, 14500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Dua Belibis Saus Sambal 340ml', 340, 50, 19500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Masako Rasa Ayam 100g', 100, 150, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Masako Rasa Sapi 100g', 100, 140, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Royco Rasa Ayam 100g', 100, 160, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Royco Rasa Sapi 100g', 100, 150, 5500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Sasa Penyedap Rasa MSG 250g', 250, 100, 10500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Mi-Won Penyedap Rasa 250g', 250, 80, 9500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Blue Band Margarine Sachet 200g', 200, 150, 10500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Blue Band Margarine Cup 250g', 250, 80, 15500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Forvita Margarine Sachet 200g', 200, 100, 8500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Kapal Api Garam Meja Beryodium 250g', 250, 150, 4500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Dolphin Garam Halus Beryodium 250g', 250, 120, 3500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Ladaku Merica Bubuk Sachet 10g', 10, 200, 1500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Desaku Kunyit Bubuk Sachet 10g', 10, 180, 1500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Desaku Ketumbar Bubuk Sachet 10g', 10, 180, 1500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL),
(NEWID(), 'Bamboe Bumbu Rendang 35g', 35, 90, 6500, 0, 1, GETDATE(), 'SYSTEM', NULL, NULL)
;

-- =======================================================================
-- Tambahan BeeMart: akun awal untuk uji coba (Admin & Kasir).
-- Brief mewajibkan seeding user; password disimpan sebagai hash PBKDF2-SHA256
-- dengan format {iterasi}.{saltBase64}.{hashBase64} (bukan plain text).
--   admin / Admin123!   (Role: Admin)
--   kasir / Kasir123!   (Role: Cashier)
-- =======================================================================
INSERT INTO [MsUser] ([IdUser], [Username], [FullName], [PasswordHash], [Role], [Stsrc], [Datein], [Userin])
VALUES
    ('00001', 'admin', 'Administrator',
     '100000.ic2LiueYtJ/jBq1yCplcxQ==.tjpU9x1lfW9mi7dA/G5zLNRkFO+4s5gcQ1PBnLm6MYk=', 'Admin', 1, GETDATE(), 'SYSTEM'),
    ('00002', 'kasir', 'Kasir Satu',
     '100000.KNV5HOM0DqHonk4m9N/hew==.9o2FV74FAdRLruJ8M2JQqOAvfy/HwGn0PbD57RaMWs0=', 'Cashier', 1, GETDATE(), 'SYSTEM');
