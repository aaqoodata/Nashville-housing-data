

-- Data cleaning In SQL

SELECT *
FROM NashvilleHousingData..NashvilleHousing
ORDER BY 1,5


--Stardadize Date Format

SELECT SaleDate, CONVERT (date, saledate)
FROM NashvilleHousingData..NashvilleHousing

UPDATE NashvilleHousingData..NashvilleHousing
SET SaleDate = CONVERT (date, saledate)

ALTER TABLE NashvilleHousingData..NashvilleHousing
Add SaleDateConverted Date; 

UPDATE NashvilleHousingData..NashvilleHousing
SET SaleDateConverted = CONVERT (date, saledate)


SELECT SaleDateConverted, CONVERT (date, saledate)
FROM NashvilleHousingData..NashvilleHousing


-- Populate Property Address

SELECT PropertyAddress
FROM NashvilleHousingData..NashvilleHousing


SELECT x.ParcelID, x.PropertyAddress, y.ParcelID, y.PropertyAddress, Isnull (x.PropertyAddress,y.PropertyAddress)
FROM NashvilleHousingData..NashvilleHousing x
Join NashvilleHousingData..NashvilleHousing y
	on x.ParcelID = y.ParcelID
	And x.[UniqueID ] <> y.[UniqueID ]
Where x.PropertyAddress is Null

-- Now let's UPDATE the PropertyAddress

UPDATE x
SET PropertyAddress = Isnull (x.PropertyAddress,y.PropertyAddress)
FROM NashvilleHousingData..NashvilleHousing x
Join NashvilleHousingData..NashvilleHousing y
	on x.ParcelID = y.ParcelID
	And x.[UniqueID ] <> y.[UniqueID ]
Where x.PropertyAddress is Null

-- Let's check our UPDATE

SELECT PropertyAddress
FROM NashvilleHousingData..NashvilleHousing
--where PropertyAddress is Null


--Breaking out Address into individual colums ( State, City, and Address)

-- Using SUBSTRING AND PARSENAME

--1- Using SUBSTRING

SELECT 
Substring (PropertyAddress, 1, Charindex (',', PropertyAddress) -1)
, Substring ( PropertyAddress, Charindex (',', PropertyAddress) +1, LEN (PropertyAddress))
FROM NashvilleHousingData..NashvilleHousing


ALTER TABLE NashvilleHousingData..NashvilleHousing
Add Property_Address Nvarchar (255); 

UPDATE NashvilleHousingData..NashvilleHousing
SET Property_Address = Substring (PropertyAddress, 1, Charindex (',', PropertyAddress) -1)

ALTER TABLE NashvilleHousingData..NashvilleHousing
Add Property_City Nvarchar (255); 

UPDATE NashvilleHousingData..NashvilleHousing
SET Property_City = Substring ( PropertyAddress, Charindex (',', PropertyAddress) +1, LEN (PropertyAddress))


-- Let's check

SELECT Property_Address, Property_City
FROM NashvilleHousingData..NashvilleHousing





--2- Using PARSENAME

SELECT 
Parsename (Replace (OwnerAddress,',', '.'), 3)
, Parsename (Replace (OwnerAddress,',', '.'), 2)
, Parsename (Replace (OwnerAddress,',', '.'), 1)
FROM NashvilleHousingData..NashvilleHousing

ALTER TABLE NashvilleHousingData..NashvilleHousing
Add Owner_Address Nvarchar (255); 

UPDATE NashvilleHousingData..NashvilleHousing
SET Owner_Address = Parsename (Replace (OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousingData..NashvilleHousing
Add Owner_City Nvarchar (255); 

UPDATE NashvilleHousingData..NashvilleHousing
SET Owner_City = Parsename (Replace (OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousingData..NashvilleHousing
Add Owner_State Nvarchar (255); 

UPDATE NashvilleHousingData..NashvilleHousing
SET Owner_State = Parsename (Replace (OwnerAddress,',', '.'), 1)

-- Let's Check

SELECT Owner_Address, Owner_City, Owner_State
FROM NashvilleHousingData..NashvilleHousing
Where OwnerAddress is not Null


-- Changing Y to Yes And N to No on SoldAsVacant
-- Let's check what we need to work on, on SoldAsVacant colum

SELECT Distinct(SoldAsVacant), Count (SoldAsVacant)
FROM NashvilleHousingData..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Now Let's Work on it.

SELECT SoldAsVacant,
	Case when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
FROM NashvilleHousingData..NashvilleHousing
--GROUP BY SoldAsVacant
--ORDER BY 2
 

 -- Let's UPDATE

 UPDATE NashvilleHousingData..NashvilleHousing
 SET SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End

SELECT SoldAsVacant
FROM NashvilleHousingData..NashvilleHousing
GROUP BY SoldAsVacant


--Remove Duplicate Rows (We can achieve this in different methods), But here we are going to use Row_Number and CTE


WITH RowNumCTE AS (
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY parcelID,
					 PropertyAddress,
					 SaleDateConverted,
					 SalePrice,
					 LegalReference
				ORDER By UniqueID
				) Row_Num
FROM NashvilleHousingData..NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE Row_Num > 1


-- Now Let Delete the duplicate row
WITH RowNumCTE AS (
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY parcelID,
					 PropertyAddress,
					 SaleDateConverted,
					 SalePrice,
					 LegalReference
				ORDER By UniqueID
				) Row_Num
FROM NashvilleHousingData..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE Row_Num > 1


-- Delete Unused Colums


SELECT *
FROM NashvilleHousingData..NashvilleHousing

ALTER TABLE NashvilleHousingData..NashvilleHousing
DROP COLUMN PropertyAddress,
			SaleDate,
			OwnerAddress,
			TaxDistrict
