
--start
select *
from PortfolioP.dbo.NashHouse

--Standardize Date Format
select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioP.dbo.NashHouse

Update NashHouse
Set SaleDate = CONVERT(Date, SaleDate)

alter table NashHouse
Add SaleDateConverted Date;

Update NashHouse
Set SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Adress Data

Select *
From PortfolioP.dbo.NashHouse
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioP.dbo.NashHouse a
Join PortfolioP.dbo.NashHouse b
 on a.ParcelID = b.ParcelID
 And a.[UniqueID ]<> b.[UniqueID ]
 Where a.PropertyAddress is null

 Update a
 set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
 From PortfolioP.dbo.NashHouse a
Join PortfolioP.dbo.NashHouse b
 on a.ParcelID = b.ParcelID
 And a.[UniqueID ]<> b.[UniqueID ]
 Where a.PropertyAddress is null

 --Breaking out Adress into Individual  Colums (adress, city, state)

 select PropertyAddress
from PortfolioP.dbo.NashHouse

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City

from PortfolioP.dbo.NashHouse

alter table NashHouse
Add PropertySplitAddress NVarchar(255);

Update NashHouse
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table NashHouse
Add PropertySplitCity NVarChar(255);

Update NashHouse
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioP.dbo.NashHouse

Select OwnerAddress
From PortfolioP.dbo.NashHouse

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioP.dbo.NashHouse

alter table NashHouse
Add OwnerSplitAddress NVarChar(255);

Update NashHouse
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

alter table NashHouse
Add OwnerSplitCity NVarChar(255);

Update NashHouse
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

alter table NashHouse
Add OwnerSplitState NVarChar(255);

Update NashHouse
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioP.dbo.NashHouse

-- Change Y and N to Yes and No  in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldasVacant)
From PortfolioP.dbo.NashHouse
Group By SoldAsVacant
Order by SoldAsVacant

select SoldAsVacant
,Case when SoldAsVacant  = 'Y' then  'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	end 
From PortfolioP.dbo.NashHouse

Update NashHouse
set SoldAsVacant = Case when SoldAsVacant  = 'Y' then  'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	end 
From PortfolioP.dbo.NashHouse

-- Remove Duplicates
With RowNumCTE as(
select * , 
  ROW_NUMBER() over (
  Partition by ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER by 
					UniqueID) Row_Num
From PortfolioP.dbo.NashHouse
--Order by ParcelID
) Delete
From RowNumCTE
WHere row_num >1
--Order By PropertyAddress

-- Delete Unused Columns (Deleteing isn't common practice but goal is to clean and standardize data)

Select *
From PortfolioP.dbo.NashHouse

Alter Table PortfolioP.dbo.NashHouse
Drop Column OwnerAddress, TaxDistrict, PropertyAdress

Alter Table PortfolioP.dbo.NashHouse
Drop Column SaleDate
-- End Project 