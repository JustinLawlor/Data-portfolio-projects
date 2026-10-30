-- Revised Oct 2026: fixed the PropertySplitAddress SUBSTRING start position, trimmed the leading space
-- from PropertySplitCity, and removed an ORDER BY that SQL Server does not allow after DELETE.

--Cleaning Data in SQL queries
Select *
From PortfolioProject1.dbo.NashvilleHousing
------------------------------------------------------------------------------------------------------------
--Standardize Date Format
Select SaleDateConverted, Convert(Date,SaleDate)
From PortfolioProject1.dbo.NashvilleHousing
 
 Update NashvilleHousing
 SET SaleDate = Convert(Date,SaleDate)

 ALTER TABLE NashvilleHousing
 Add SaleDateConverted Date; 
 
  Update NashvilleHousing
 SET SaleDateConverted = Convert(Date,SaleDate)

------------------------------------------------------------------------------------------------------------
--Populate Address Data
Select *
From PortfolioProject1.dbo.NashvilleHousing
--Where PropertyAddress is Null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
Join PortfolioProject1.dbo.NashvilleHousing b
On a.ParcelID = b.ParcelID 
And a.[UniqueID] < >b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
Join PortfolioProject1.dbo.NashvilleHousing b
On a.ParcelID = b.ParcelID 
And a.[UniqueID] < >b.[UniqueID]
------------------------------------------------------------------------------------------------------------
--Breaking Out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject1.dbo.NashvilleHousing
--Where PropertyAddress is Null
--Order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address


From PortfolioProject1.dbo.NashvilleHousing

 
 ALTER TABLE NashvilleHousing
 Add PropertySplitAddress Nvarchar(255); 
 
    Update NashvilleHousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

  ALTER TABLE NashvilleHousing
 Add PropertySplitcity nvarchar(255); 

   Update NashvilleHousing
 SET PropertySplitCity = LTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)))

 Select *
 From PortfolioProject1.dbo.NashvilleHousing



 Select OwnerAddress
 From PortfolioProject1.dbo.NashvilleHousing



 Select PARSENAME(Replace(OwnerAddress,',','.'),3)
 , PARSENAME(Replace(OwnerAddress,',','.'),2)
 ,PARSENAME(Replace(OwnerAddress,',','.'),1)
  From PortfolioProject1.dbo.NashvilleHousing

   ALTER TABLE NashvilleHousing
 Add OwnerSplitAddress Nvarchar(255); 
 
     Update NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

  ALTER TABLE NashvilleHousing
 Add OwnerSplitcity nvarchar(255); 

   Update NashvilleHousing
 SET OwnerSplitcity = PARSENAME(Replace(OwnerAddress,',','.'),2)
 
  ALTER TABLE NashvilleHousing
 Add OwnerSplitState nvarchar(255); 

   Update NashvilleHousing
 SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vaccant" field

Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
 From PortfolioProject1.dbo.NashvilleHousing
 Group by SoldAsVacant
 Order by 2

 Select  SoldAsVacant
 , CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
 From PortfolioProject1.dbo.NashvilleHousing

 Update NashvilleHousing
 SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End

------------------------------------------------------------------------------------------------------------
--Remove Duplicates
With Row_numCTE as(
Select *, 
	ROW_NUMBER() Over (
	Partition by ParcelID, PropertyAddress, 
	SalePrice, SaleDate,LegalReference
	Order by 
		UniqueID
		) row_num

 From PortfolioProject1.dbo.NashvilleHousing
 --Order by ParcelID
 )
Delete
From Row_numCTE
 Where row_num > 1
 


------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

Select *
From PortfolioProject1.dbo.NashvilleHousing

Alter Table PortfolioProject1.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject1.dbo.NashvilleHousing
Drop Column SaleDate