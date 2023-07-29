//Credit to Ficool2
::GetPropArraySize <- ::NetProps.GetPropArraySize.bindenv(::NetProps);
::GetPropEntity <- ::NetProps.GetPropEntity.bindenv(::NetProps);
::GetPropEntityArray <- ::NetProps.GetPropEntityArray.bindenv(::NetProps);
::GetPropBool <- ::NetProps.GetPropBool.bindenv(::NetProps);
::GetPropBoolArray <- ::NetProps.GetPropBoolArray.bindenv(::NetProps);
::GetPropFloat <- ::NetProps.GetPropFloat.bindenv(::NetProps);
::GetPropFloatArray <- ::NetProps.GetPropFloatArray.bindenv(::NetProps);
::GetPropInfo <- ::NetProps.GetPropInfo.bindenv(::NetProps);
::GetPropInt <- ::NetProps.GetPropInt.bindenv(::NetProps);
::GetPropIntArray <- ::NetProps.GetPropIntArray.bindenv(::NetProps);
::GetPropString <- ::NetProps.GetPropString.bindenv(::NetProps);
::GetPropStringArray <- ::NetProps.GetPropStringArray.bindenv(::NetProps);
::GetPropType <- ::NetProps.GetPropType.bindenv(::NetProps);
::GetPropVector <- ::NetProps.GetPropVector.bindenv(::NetProps);
::GetPropVectorArray <- ::NetProps.GetPropVectorArray.bindenv(::NetProps);
::GetTable <- ::NetProps.GetTable.bindenv(::NetProps);
::HasProp <- ::NetProps.HasProp.bindenv(::NetProps);
::SetPropBool <- ::NetProps.SetPropBool.bindenv(::NetProps);
::SetPropBoolArray <- ::NetProps.SetPropBoolArray.bindenv(::NetProps);
::SetPropEntity <- ::NetProps.SetPropEntity.bindenv(::NetProps);
::SetPropEntityArray <- ::NetProps.SetPropEntityArray.bindenv(::NetProps);
::SetPropFloat <- ::NetProps.SetPropFloat.bindenv(::NetProps);
::SetPropFloatArray <- ::NetProps.SetPropFloatArray.bindenv(::NetProps);
::SetPropInt <- ::NetProps.SetPropInt.bindenv(::NetProps);
::SetPropIntArray <- ::NetProps.SetPropIntArray.bindenv(::NetProps);
::SetPropString <- ::NetProps.SetPropString.bindenv(::NetProps);
::SetPropStringArray <- ::NetProps.SetPropStringArray.bindenv(::NetProps);
::SetPropVector <- ::NetProps.SetPropVector.bindenv(::NetProps);
::SetPropVectorArray <- ::NetProps.SetPropVectorArray.bindenv(::NetProps);

::AddPropFloat <- function(entity, property, value)
{
    SetPropFloat(entity, property, GetPropFloat(entity, property) + value)
}

::AddPropInt <- function(entity, property, value)
{
    SetPropInt(entity, property, GetPropInt(entity, property) + value)
}