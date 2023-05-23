-- Cleaning data 
select * 
From PortfolioProject..NashvilleHousing

-- Standardize date format
Select SaleConvertedDate, Convert(Date,SaleDate)
From PortfolioProject..NashvilleHousing

update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleConvertedDate Date

update NashvilleHousing
SET SaleConvertedDate = Convert(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------


--Populate Property address data
Select *
From PortfolioProject..NashvilleHousing
order by ParcelID


Select a.[UniqueID ],a.ParcelID,a.PropertyAddress,b.[UniqueID ],b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
	JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
Set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
	JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------
--Breaking out Address into individual columns (Address, City and State)
Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address

From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

update PortfolioProject..NashvilleHousing
Set PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

update PortfolioProject..NashvilleHousing
Set OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

update PortfolioProject..NashvilleHousing
Set OwnerSplitState =PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Solid as Vacant field"





SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
		 WHEN SoldAsVacant ='N' THEN 'No'
		 ELSE SoldAsVacant
		 END

FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
		 WHEN SoldAsVacant ='N' THEN 'No'
		 ELSE SoldAsVacant
		 END

---------------------------------------------------------------------------------------------------------------

---Remove Duplicates 
WITH Row_numCTE AS(
SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 ORDER BY
					 UniqueID
					 ) row_num
		
FROM PortfolioProject..NashvilleHousing
)
DELETE 
FROM Row_numCTE
WHERE row_num > 1

----------------------------------------------------------------------------------------------------------------------------------


--Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
