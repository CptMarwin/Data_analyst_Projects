select *
from PortfolioProject..NashvilleHousing

-------

select SaleDate
from PortfolioProject..NashvilleHousing

------
--Change from date time to date format

alter table nashvillehousing
alter column [SaleDate] date

-- Ez itt rossz mivel: Az első lekérdezés, ahol az ALTER TABLE utasítással változtatod meg a SaleDate oszlop típusát, módosítja a tábla struktúráját, de nem módosítja az oszlopokban lévő adatokat. 
--Az ALTER utasítás csak a tábla definícióját változtatja meg, nem az adatokat.
--A második lekérdezésben, ahol az UPDATE utasítással próbálod az SaleDate oszlopban lévő értékeket konvertálni, észrevettem egy potenciális problémát: a CONVERT függvényt nem megfelelően használod.
--Update NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

--populate Property address

select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

-- Breaking out address into individual column (address, city, state)

select
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyAddress) -1) as Address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyAddress) +1, LEN(PropertyAddress))  as Address
from PortfolioProject..NashvilleHousing

ALter table NAshvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyAddress) -1)


ALter table NAshvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyAddress) +1, LEN(PropertyAddress))

select *
from NashvilleHousing

------- Owner Address split

select
PARSENAME(REPLACE(Owneraddress, ',','.'),3) as Address,
PARSENAME(REPLACE(Owneraddress, ',','.'),2) as City,
PARSENAME(REPLACE(Owneraddress, ',','.'),1) as State
from PortfolioProject..NashvilleHousing

ALter table NAshvilleHousing
Add OwnerSplitAddress Nvarchar(255), 
OwnerSplitCity Nvarchar(255), 
OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(Owneraddress, ',','.'),3),

OwnerSplitCity = PARSENAME(REPLACE(Owneraddress, ',','.'),2),

OwnerSplitState = PARSENAME(REPLACE(Owneraddress, ',','.'),1)

-------- Change Y and N to Yes and No in SoldasVacant field

select SoldAsVacant,
 CASE when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 END

from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 END

 -- Remove duplicates

With RowNumCTE as(
select *,
ROW_NUMBER() over (
	partition by parcelID, PropertyAddress, SalePrice, SaleDate,LegalReference order by uniqueID) row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where  row_num > 1

-- delete unused columns

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
Drop	column Owneraddress,Taxdistrict, PropertyAddress

