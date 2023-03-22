/*
Cleaning Data in SQL Queries
*/

Select *
From DataCleaningProject.dbo.Housing

-- Standardize Data Format --

Select SaleDateConverted, Convert(date,SaleDate)
From DataCleaningProject.dbo.Housing

Alter Table Housing
add SaleDateConverted Date;

Update Housing
Set SaleDateConverted = Convert(date,SaleDate)

-- Populate Property Address Data -- 

Select *
From DataCleaningProject.dbo.Housing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From DataCleaningProject.dbo.Housing a
Join DataCleaningProject.dbo.Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From DataCleaningProject.dbo.Housing a
Join DataCleaningProject.dbo.Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Wher a.PropertyAddress is null

-- Breaking out Address into Individual Colums (Address, City, State) --

Select PropertyAddress
From DataCleaningProject.dbo.Housing
--Where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

From DataCleaningProject.dbo.Housing

Alter Table Housing
add PropertySplitAddress nvarchar(255);

Update Housing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table Housing
add PropertySplitCity varchar(255);

Update Housing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From DataCleaningProject.dbo.Housing


Select OwnerAddress
From DataCleaningProject.dbo.Housing

Select
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From DataCleaningProject.dbo.Housing

Alter Table Housing
add OwnerSplitAddress nvarchar(255);

Update Housing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table Housing
add OwnerSplitCity varchar(255);

Update Housing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table Housing
add OwnerSplitState varchar(255);

Update Housing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From DataCleaningProject.dbo.Housing

-- Change Y and N to Yes and No in "Sold as Vacant" field --

Select Distinct(SoldAsVacant) , Count(SoldAsVacant)
From DataCleaningProject.dbo.Housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From DataCleaningProject.dbo.Housing

Update Housing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End

-- Remove Duplicates -- 

With RowNumCTE As(
Select *,
	Row_Number() OVER(
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
					UniqueID
					) row_num
				
From DataCleaningProject.dbo.Housing
)
Select *
--DELETE
From RowNumCTE
Where row_num > 1

Select *
From DataCleaningProject.dbo.Housing

-- Delete Unused Columns --

Select *
From DataCleaningProject.dbo.Housing

Alter Table DataCleaningProject.dbo.Housing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table DataCleaningProject.dbo.Housing
Drop Column SaleDate