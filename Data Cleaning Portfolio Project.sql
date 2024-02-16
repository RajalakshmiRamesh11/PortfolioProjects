/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, Convert(Date, SaleDate)
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)


-- If it doesn't Update properly

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)


--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select PropertyAddress
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null
--Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing


Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) As Address
From PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(250);

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(250);

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))



Select *
From PortfolioProject..NashvilleHousing


Select OwnerAddress
From PortfolioProject..NashvilleHousing


Select
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing



Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(250);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)



Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(250);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)



Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(250);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)



Select *
From PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2


Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
  End
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
                        When SoldAsVacant = 'N' Then 'No'
	                    Else SoldAsVacant
                   End




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE As(
Select *,
        Row_Number() Over (
        Partition By ParcelID,
                                 PropertyAddress,
				                 SalePrice,
				                 SaleDate,
				                 LegalReference  
				                 Order By
				                        UniqueID
				                        ) row_num
From PortfolioProject..NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress



Select *
From PortfolioProject..NashvilleHousing



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing



Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

