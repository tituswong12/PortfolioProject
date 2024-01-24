--Cleaning Data in SQL Queries

Select* 
FROM NashvilleHousing


--Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousing


Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address Data

Select *
FROM NashvilleHousing

--Where PropertyAddress is NULL
order by ParcelID


--ISNULL checks to see if the first item is null and if it is null it wil return the second item
Select uni.ParcelID, uni.PropertyAddress, nonuni.ParcelID, nonuni.PropertyAddress, ISNULL(uni.propertyAddress, nonuni.PropertyAddress)
FROM NashvilleHousing uni
JOIN NashvilleHousing nonuni
	on uni.ParcelID = nonuni.ParcelID
	AND uni.[UniqueID ] <> nonuni.[UniqueID]
WHERE uni.PropertyAddress is  NULL


Update uni
SET PropertyAddress = ISNULL(uni.propertyAddress, nonuni.PropertyAddress)
FROM NashvilleHousing uni
JOIN NashvilleHousing nonuni
	on uni.ParcelID = nonuni.ParcelID
	AND uni.[UniqueID ] <> nonuni.[UniqueID]
WHERE uni.PropertyAddress is null


--Breaking out Address into INdividual Columns (Adress, City, State)
Select PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,  LEN(PropertyAddress)) as Address
FROM NashvilleHousing


Alter Table NashvilleHousing
Add propertySplitAddress nvarchar(255);

Update NashvilleHousing
Set propertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


Alter Table NashvilleHousing
Add propertySplitCity nvarchar(255);

Update NashvilleHousing
Set propertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,  LEN(PropertyAddress))


--Split Owner Address


Select 
Parsename(REPLACE(ownerAddress,',','.'),3),
Parsename(REPLACE(ownerAddress,',','.'),2),
Parsename(REPLACE(ownerAddress,',','.'),1) 
FROM NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress  = Parsename(REPLACE(ownerAddress,',','.'),3)


Alter Table NashvilleHousing
Add OwnerSplitCity  nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity  = Parsename(REPLACE(ownerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState  nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState  = Parsename(REPLACE(ownerAddress,',','.'),1)

Select OwnerSplitAddress, OwnerSplitCity,OwnerSplitState
FROM NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
CASE WHen SoldAsVacant = 'Y' THEN 'Yes'
	 WHen SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE WHen SoldAsVacant = 'Y' THEN 'Yes'
	 WHen SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--Remove Duplicates


WITH RowNumCTE AS(
Select*,
ROW_Number() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER  BY 
					UniqueID
					) row_num


FROM NashvilleHousing
--ORDER by ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1



--Delete Unused Columns


Select*
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress
