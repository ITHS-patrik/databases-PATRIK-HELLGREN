declare @json NVARCHAR(Max) = '
    {
        "Id": 10248,
        "Customer": "VINET 5",
        "Timestamps": {
            "OrderDate": "2012-07-04",
            "RequiredDate": "2012-08-01",
            "ShippedDate": "2012-07-16"
        },
        "ShipVia": 3,
        "Freight": 1.675000000000000e+001,
        "ShipInfo": {
            "Name": "Vins et alcools Chevalier",
            "Location": {
                "Address": "59 rue de lAbbaye",
                "City": "Reims",
                "Region": "Western Europe",
                "PostalCode": "51100",
                "Country": "France"
            }
        }
    }
'

--select json_value(@json, '$.ShipInfo.Location.City')

declare @json NVARCHAR(Max) = (select * from openrowset(BULK 'c:\backups\orders.json', SINGLE_NCLOB) as import)

select * from openjson(@json) with (
	Id int,
	Customer nvarchar(15),
	--Timestamps nvarchar(max) as json,
	OrderDate datetime2 '$.Timestamps.OrderDate',
	RequiredDate datetime2 '$.Timestamps.RequiredDate',
	ShippedDate datetime2 '$.Timestamps.ShippedDate',
	ShipInfo nvarchar(max) as json
)

