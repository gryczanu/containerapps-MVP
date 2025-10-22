@sealed()
@export()
type modelConfiguration = {
  @minLength(3)
  name: string
  imageVersion: string
  buildId: string
  latestCommit: string
  endpoint: string
  endpointName: string
}

@export()
type models = modelConfiguration[]

@export()
@sealed()
type acaEndpoint = {
  name: string
  fqdn: string
}

@export()
type acaEndpoints = acaEndpoint[]

@sealed()
@export()
type environmentConfiguration = {
  env: string
  resourceGroup: string
  location: string
  shortLocation: string
  environmentName: string
  acrName: string
  acrEndpoint: string
}
