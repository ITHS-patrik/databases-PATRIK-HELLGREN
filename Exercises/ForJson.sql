SELECT TOP (1000) 
    Id,
    concat(CustomerId, ' ', EmployeeId) as 'Customer',
    OrderDate as 'Timestamps.OrderDate',
    RequiredDate as 'Timestamps.RequiredDate',
    ShippedDate as 'Timestamps.ShippedDate',
    ShipVia,
    Freight,
    ShipName as 'ShipInfo.Name',
    ShipAddress as 'ShipInfo.Location.Address',
    ShipCity as 'ShipInfo.Location.City',
    ShipRegion as 'ShipInfo.Location.Region',
    ShipPostalCode as 'ShipInfo.Location.PostalCode',
    ShipCountry as 'ShipInfo.Location.Country'
FROM 
    everyloop.company.orders
for json path

-- Uppgift: Lägg OrderDate, RequiredDate och ShippedDate i ett json objekt "TimeStamps".

select * from company.orders o join company.order_details [Rows] on o.Id = [Rows].OrderId for json auto, root('Orders')