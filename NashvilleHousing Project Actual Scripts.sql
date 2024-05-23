/*
Cleaning Data in SQL Queries
*/

SELECT 
	*
FROM
	NashvilleHousing

----Standardize date format----
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT 
	SaleDate, SaleDateConverted
FROM
	NashvilleHousing

----Populate Property Address data----

/*SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL
*/

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

----Breaking out Addresses into Individual Columns (Address, City, State)----
--SELECT
--	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
--	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
--FROM
--	NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT 
	PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM
	NashvilleHousing

--SELECT
--	PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
--	PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
--	PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
--FROM
--	NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM NashvilleHousing


----Change Y and N to Yes and No in "Sold as Vacant" field----
SELECT 
	SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM
	NashvilleHousing

UPDATE NashvilleHousing
SET
	SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM 
	NashvilleHousing

SELECT
	DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM
	NashvilleHousing
GROUP BY
	SoldAsVacant


----Remove Duplicates----
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM
	NashvilleHousing
)

DELETE 
FROM RowNumCTE
WHERE row_num > 1


----Delete Unsused Columns----
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

--SELECT OwnerAddress, PropertyAddress, TaxDistrict
--FROM NashvilleHousing
