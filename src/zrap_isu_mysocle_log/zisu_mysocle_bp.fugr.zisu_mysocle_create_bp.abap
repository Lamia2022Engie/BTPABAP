FUNCTION ZISU_MYSOCLE_CREATE_BP.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"----------------------------------------------------------------------
 " You can use the template 'functionModuleParameter' to add here the signature!


   DATA(lo_rfc_dest) = cl_rfc_destination_provider=>create_by_cloud_destination(
                               i_name = |FSD_RFC|
                               i_service_instance_name = |CA_EXTERNAL_API_SIN| ).




ENDFUNCTION.
