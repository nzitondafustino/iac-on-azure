var location = resourceGroup().location
var routeTablename = 'spoke-route-table'

// Reference the existing subnet
// Reference existing subnets

resource routeTable 'Microsoft.Network/routeTables@2019-11-01' = {
  name: routeTablename
  location: location
}


output routeTableId string = routeTable.id
output routeTableName string = routeTable.name
