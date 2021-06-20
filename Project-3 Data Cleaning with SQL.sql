/*
Cleaning data in Sql Query
*/

Select *
from NashvilleHousing


-- 1.Standardize date format

Select SaleDateUpdated, CONVERT(Date, SaleDate)
from NashvilleHousing

/*Update NashvilleHousing                   
Set SaleDate = CONVERT(Date, SaleDate)*/    --It's not Working many times

Alter Table NashvilleHousing
Add SaleDateUpdated Date

Update NashvilleHousing
Set SaleDateUpdated = Convert(Date, SaleDate)


--2. Fill null Address

Select *
From NashvilleHousing
Where PropertyAddress is Null

Select *                                       -- we can see that if parcelId is same then Address will be same
From NashvilleHousing
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)   -- ISNULL use to put value b in a if a is null  
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Now update Value 

Update a
Set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]

--- Breaking address into individual column (address,city)

select PropertyAddress
from NashvilleHousing

select PropertyAddress, SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address   --CHARINDEX give index of the character 
, Substring( PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) As City
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
set PropertySplitCity = Substring( PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From NashvilleHousing

Select OwnerAddress,
PARSENAME( REPLACE( OwnerAddress, ',', '.'), 1),              -- PARSENAME work only on '.' and in reverse order
PARSENAME( REPLACE( OwnerAddress, ',', '.'), 2),
PARSENAME( REPLACE( OwnerAddress, ',', '.'), 3)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME( REPLACE( OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
set OwnerSplitCity = PARSENAME( REPLACE( OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
set OwnerSplitState = PARSENAME( REPLACE( OwnerAddress, ',', '.'), 1)



--- change y and n too YES and NO in SoldAsVacant
 Select Distinct( SoldAsVacant), Count( SoldAsVacant)
 From NashvilleHousing
 Group by SoldAsVacant
 Order by 2

Select SoldAsVacant,
CASE
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End


--- remove Duplicate entry

With RowNumCte As(
Select * ,
	ROW_NUMBER() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDAte,
				 LegalReference
				 Order by UniqueID
			) row_num
From NashvilleHousing
)

/*Select * From RowNumCte          -- here 104 row are Duplicate
Where row_num >1 */
Delete  
From RowNumCte
Where row_num>1


-- Delete unused Column

Select * 
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
