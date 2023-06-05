-- Cleaning data in SQL

SELECT *
FROM Housing

-- (1) Changing date format

SELECT SaleDateConv, CONVERT(date, SaleDate)
FROM Housing

ALTER TABLE Housing
ADD SaleDateConv Date;

UPDATE Housing
SET SaleDateConv = CONVERT(date, SaleDate)





-- (2) Populating 'PropertyAddress' data

SELECT *
FROM Housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


-- Doing self-join
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL





-- (3) Breaking 'Address' column into seperate columns (address, city, state)

SELECT PropertyAddress
FROM Housing
--WHERE PropertyAddress IS NULL

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM Housing


--Creating two new columns PropertySplitAddress & PropertySplitCity
ALTER TABLE Housing
ADD PropertySplitAddress nvarchar(255);

UPDATE Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Housing
ADD PropertySplitCity nvarchar(255);

UPDATE Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))





-- (4) Modifying 'OwnerAddress' column

SELECT OwnerAddress
FROM Housing

-- NOTE: PARSENAME function only looks for period (NOT comma)
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Housing

-- Adding OwnerSplitAddress
ALTER TABLE Housing
ADD OwnerSplitAddress nvarchar(255);

UPDATE Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-- Adding OwnerSplitCity
ALTER TABLE Housing
ADD OwnerSplitCity nvarchar(255);

UPDATE Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- Adding OwnerSplitState
ALTER TABLE Housing
ADD OwnerSplitState nvarchar(255);

UPDATE Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)





-- (5) Replacing 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant column

SELECT DISTINCT SoldAsVacant, count(SoldAsVacant)
FROM Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Housing


UPDATE Housing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END





-- (6) Removing duplicates

WITH RowNumCTE as(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID
) as row_num
FROM Housing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress





-- (7) Deleting unused columns

SELECT *
FROM Housing

ALTER TABLE Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
