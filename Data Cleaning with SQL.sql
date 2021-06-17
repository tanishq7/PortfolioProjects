/* Cleaning Housing Data */

select * from Projects..NashvilleHousing

--Standardize Sale Date

select SaleDate, convert(date,SaleDate) from Projects..NashvilleHousing

update Projects.. NashvilleHousing
set SaleDate = convert(date,SaleDate)

alter table Projects..NashvilleHousing
add SaleDateConverted Date; 

update Projects.. NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

--Populate Property Address Data

select * from Projects..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Projects..NashvilleHousing a
join Projects..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress =ISNULL(a.PropertyAddress,b.PropertyAddress) 
from Projects..NashvilleHousing a
join Projects..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]


--Breaking down Address into Individual Colummns

select PropertyAddress from Projects..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress)) as Address
from Projects..NashvilleHousing

alter table Projects..NashvilleHousing
add PropertySplitAddress nvarchar(255)

update Projects.. NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

alter table Projects..NashvilleHousing
add PropertySplitCity nvarchar(255)

update Projects.. NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress))

select *
from Projects..NashvilleHousing




-- alternative method

select OwnerAddress
from Projects..NashvilleHousing

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)

from Projects..NashvilleHousing

alter table Projects..NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update Projects.. NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table Projects..NashvilleHousing
add OwnerSplitCity nvarchar(255)

update Projects.. NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table Projects..NashvilleHousing
add OwnerSplitState nvarchar(255)

update Projects.. NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

select *
from Projects..NashvilleHousing

-- Change Y/N to Yes/No in 'Sold as Vacant'

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from Projects..NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

from Projects..NashvilleHousing

update Projects.. NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

--remove duplicates

with RowNumCTE as (
select *, 
ROW_NUMBER() over (
partition by ParcelID, PropertyAddress,SalePrice, Saledate, LegalReference
order by UniqueID ) row_num

from Projects..NashvilleHousing
--order by ParcelID
)

delete 
from RowNumCTE
where row_num > 1
--order by PropertyAddress

--Delete unused columns

alter table Projects..NashvilleHousing
drop column OwnerAddress


