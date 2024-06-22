-- Cleaning Data with SQL Queries

--Standerdizing Date Format

Select
	SaleDateStandard, 
	CONVERT(Date, SaleDate)
From
	PortfolioProject.dbo.NashvilleHousing

Update
	NashvilleHousing
Set 
	SaleDate = CONVERT(Date, SaleDate)

--Sale Date is not converting so we will use Alter table function

Alter Table
	NashvilleHousing
Add
	SaleDateStandard Date;

Update 
	NashvilleHousing
Set
	SaleDateStandard = CONVERT(Date,SaleDate)

-- Populate Property Address Data

Select
	*
From
	PortfolioProject.dbo.NashvilleHousing
--Where 
	--PropertyAddress is null
Order By
	ParcelID

-- ParcelID is linked to property address, repeated ParcelIDs have the same address
-- Use ParcelID to populate the address data

Select
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress,b.PropertyAddress)
From
	PortfolioProject.dbo.NashvilleHousing a
JOIN
	PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where 
	a.PropertyAddress is null

Update
	a
Set
	PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From
	PortfolioProject.dbo.NashvilleHousing a
JOIN
	PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

-- Splitting Full Address into Columns (Address, City, State)

Select
	PropertyAddress
From
	PortfolioProject.dbo.NashvilleHousing

-- Use Substring function to split address into own columns

Select *
	--SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)- 1) as Address,
	--SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress)) as City
From
	PortfolioProject.dbo.NashvilleHousing

-- Updating Property Address Column with new seperated (Addres,City,Sate)

Alter Table
	NashvilleHousing
Add
	PropertySplitAddress Nvarchar(255);

Update 
	NashvilleHousing
Set
	PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)- 1)
----------------------------------------------------------------------------------------------------------------
Alter Table
	NashvilleHousing
Add
	PropertySplitCity Nvarchar(255);

Update 
	NashvilleHousing
Set
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress))
-------------------------------------------------------------------------------------------------------------------------------
Select
	PropertySplitAddress, 
	PropertySplitCity
From
	PortfolioProject.dbo.NashvilleHousing

--Splitting up Owner Address into (Address,City,States) using PARSENAME

Select
	OwnerAddress
From
	PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------

Select
	PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

From
	PortfolioProject.dbo.NashvilleHousing

--Adding in the columns for split owner address

Alter Table
	NashvilleHousing
Add
	OwnerSplitAddress Nvarchar(255);

Update 
	NashvilleHousing
Set
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Alter Table
	NashvilleHousing
Add
	OwnerSplitCity Nvarchar(255);

Update 
	NashvilleHousing
Set
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

Alter Table
	NashvilleHousing
Add
	OwnerSplitState Nvarchar(255);

Update 
	NashvilleHousing
Set
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

Select
	OwnerSplitAddress,
	OwnerSplitCity,
	OwnerSplitState
From
	PortfolioProject.dbo.NashvilleHousing

-- Converting Y and N to Yes and No in SoldAsVacant column
-- Using Distinct function to check all values

Select
	Distinct(SoldAsVacant), COUNT(SoldAsVacant) as Occurences
From
	PortfolioProject.dbo.NashvilleHousing
Group By
	SoldAsVacant
Order By 
	2
-------------------------------------------------------------------------------------------------

Select
	SoldAsVacant,
	Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
From
	PortfolioProject.dbo.NashvilleHousing

Update 
	NashvilleHousing
Set
	SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END

-- Removing Duplicates With Row_Number function
-- Looking through ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference for duplicates
-- Any Duplicates will be assigned a row_number > 1

With
	RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	Partition By ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
				 UniqueID
				 ) row_num

From
	PortfolioProject.dbo.NashvilleHousing
)
Select *
--Delete

From
	RowNumCTE
Where
	row_num > 1
Order By
	PropertyAddress

-- Delete Unused Columns

Select *

From
	PortfolioProject.dbo.NashvilleHousing

Alter Table
	PortfolioProject.dbo.NashvilleHousing
Drop Column
	OwnerAddress, 
	TaxDistrict,
	PropertyAddress,
	SaleDate

Select *

From
	PortfolioProject.dbo.NashvilleHousing
