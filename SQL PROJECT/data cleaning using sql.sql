/*-----

Cleaning Data using  SQL Queries

*/---------------



select *
from nashvilhousing

----------------------------------------------------------------------------------------------------------------------------


-- standardize date format

select (CONVERT(Date,SaleDate) , SaleDateConverted
from nashvilhousing

update nashvilhousing
set SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

alter table nashvilhousing
add SaleDateConverted date

Update nashvilhousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From nashvilhousing
Where PropertyAddress is not null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From nashvilhousing a
JOIN nashvilhousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From nashvilhousing a
JOIN nashvilhousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)



Select PropertyAddress
From nashvilhousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From nashvilhousing


ALTER TABLE nashvilhousing
Add PropertySplitAddress Nvarchar(255);

Update nashvilhousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE nashvilhousing
Add PropertySplitCity Nvarchar(255);

Update nashvilhousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From nashvilhousing





Select OwnerAddress
From nashvilhousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From nashvilhousing


ALTER TABLE nashvilhousing
Add OwnerSplitAddress Nvarchar(255);

Update nashvilhousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE nashvilhousing
Add OwnerSplitCity Nvarchar(255);

Update nashvilhousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE nashvilhousing
Add OwnerSplitState Nvarchar(255);

Update nashvilhousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From nashvilhousing

---------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashvilhousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From nashvilhousing


Update nashvilhousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From nashvilhousing
--order by ParcelID
)
Select *   --//delete
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From nashvilhousing



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From nashvilhousing


ALTER TABLE nashvilhousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

