/* Display all rows in the "housingdata" table, ordered by SaleDate. */
select * from housingdata order by SaleDate;

/* Remove the column "Salesdata_new" from the "housingdata" table. */
ALTER TABLE housingdata
DROP COLUMN Salesdata_new;
/* Describe the "SaleDate" column of the "housingdata" table. */
describe housingdata SaleDate;

/* Select "SaleDate" and its converted date "ConvertedSaleDate" from the "housingdata" table. */
SELECT SaleDate, DATE(SaleDate) AS ConvertedSaleDate FROM housingdata;

/* Update the "SaleDate" column in the "housingdata" table to store only the date part. */
UPDATE housingdata
SET SaleDate = DATE(SaleDate);

/* Populate "property" data by selecting all rows from the "housingdata" table, ordered by ParcelID. */
SELECT 
    *
FROM
    housingdata
ORDER BY ParcelID;

/* Display ParcelID, PropertyAddress, and a merged PropertyAddress (with NULL values replaced). */
SELECT 
    a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress) AS MergedPropertyAddress
FROM
    housingdata a
JOIN 
    housingdata b
ON 
    a.ParcelID = b.ParcelID
AND 
    a.UniqueID <> b.UniqueID
WHERE 
    a.PropertyAddress IS NULL;




/* Separate the address and city from the PropertyAddress column. */
SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS address
    ,SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, length(PropertyAddress)) AS City
FROM 
    housingdata;

/* Add the columns "PropertySplitAddress" and "PropertySplitCity" to the "housingdata" table. */
SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) AS City
FROM 
    housingdata;


/* Add the columns "PropertySplitAddress" and "PropertySplitCity" to the "housingdata" table. */
ALTER TABLE housingdata
ADD PropertySplitAddress NVARCHAR(255);

/* Update "PropertySplitAddress" with the address part and "PropertySplitCity" with the city part. */
UPDATE housingdata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE housingdata
ADD PropertySplitCity NVARCHAR(255);

UPDATE housingdata
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

/* different way to seperate the values Separate the parts of the OwnerAddress column and display them as individual columns. */
select OwnerAddress from housingdata;
SELECT
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1), '.', 1) AS ThirdPart,
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1) AS SecondPart,
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3), '.', 1) AS FirstPart
FROM  housingdata;


-- Add OwnerSplitAddress column to the table
ALTER TABLE housingdata
ADD OwnerSplitAddress NVARCHAR(255);

-- Update OwnerSplitAddress with the third part of the OwnerAddress
UPDATE housingdata
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3), '.', 1);

-- Add OwnerSplitCity column to the table
ALTER TABLE housingdata
ADD OwnerSplitCity NVARCHAR(255);

-- Update OwnerSplitCity with the second part of the OwnerAddress
UPDATE housingdata
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1);

-- Add OwnerSplitState column to the table
ALTER TABLE housingdata
ADD OwnerSplitState NVARCHAR(255);

-- Update OwnerSplitState with the first part of the OwnerAddress
UPDATE housingdata
SET OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1);

-- Select all columns from the table
SELECT *
FROM housingdata;

/* Count the occurrences of each unique value in the "SoldAsVacant" column and display the results. */
select distinct(SoldAsVacant),count(SoldAsVacant)
from housingdata
group by SoldAsVacant
order by 2;

/* Transform "SoldAsVacant" values from Y and N  to "Yes" or "No". */
SELECT 
    SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS TransformedSoldAsVacant
FROM housingdata
group by 1;

/* Update the "SoldAsVacant" column with "Yes" or "No". */
UPDATE housingdata
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END;
/* Count the occurrences of each unique value in the "SoldAsVacant" column and display the results*/
SELECT SoldAsVacant,count(SoldAsVacant)
FROM housingdata
group by 1 ;

/* Create a Common Table Expression (CTE) named RowNumCTE to assign row numbers to each row based on certain criteria. */

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM housingdata -- Make sure to use the correct table name here
)




-- Select all columns from the CTE where row_num is greater than 1 and order the results by PropertyAddress.
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

CREATE TEMPORARY TABLE TempDuplicateRows AS
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY ParcelID,
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
           ORDER BY UniqueID
       ) AS row_num
FROM housingdata;

-- Delete the duplicate rows (where row_num > 1) from the "housingdata" table using the temporary table.
DELETE FROM housingdata
WHERE UniqueID IN (
    SELECT UniqueID
    FROM TempDuplicateRows
    WHERE row_num > 1
);

-- Drop the temporary table.
DROP TEMPORARY TABLE IF EXISTS TempDuplicateRows;

select TempDuplicateRows from housingdata;


-- Select all columns from the "NashvilleHousing" table (if needed).
SELECT *
FROM housingdata;



