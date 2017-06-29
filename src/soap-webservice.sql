----------------------
-- OVERVIEW --
-- Make call via plsql alex util and apex_web_service
----------------------

-- Create user if not exist
-- - Not needed - apex user makes the request: APEX_050000

-- Grant via dbms_network_acl_admin
begin
    -- Not limiting ports for 'connect' privilege so doing it with 'resolve' together.
    -- Otherwise, have to separate into two append_host_ace calls because 'resolve'
    --   doesn't take lower_port and upper_port parameters
    dbms_network_acl_admin.append_host_ace(
        host => 'services.aonaware.com',
        ace => xs$ace_type (
            privilege_list => xs$name_list('connect', 'resolve'),
            principal_name => 'APEX_050000',
            principal_type => 'xs_acl.ptype_db'
        )
    );
end;

-- Make soap call to test web service:
--  http://free-web-services.com/
--  http://services.aonaware.com/DictService/DictService.asmx
declare
  l_env          t_soap_envelope;
  l_xml          xmltype;
begin

  -- the t_soap_envelope type can be used to generate a typical SOAP request envelope with just a few lines of code

  debug_pkg.debug_on;

  -- alexandria soap envelope not generic enough so need to create envelope manually
  l_env := t_soap_envelope (
    'http://services.aonaware.com',
    'DictService/DictService.asmx',
    'webservices/Define',
    'xmlns="http://services.aonaware.com/webservices"');
  l_env.add_param ('word', 'bird');

  -- if Apex 4+ is available:
  l_xml := apex_web_service.make_request (
    p_url => l_env.service_url,
    p_action => l_env.soap_action,
    p_envelope => '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://www.w3.org/2003/05/soap-envelope" xmlns:s="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/" xmlns:tns="http://services.aonaware.com/webservices/" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:tm="http://microsoft.com/wsdl/mime/textMatching/" xmlns:http="http://schemas.xmlsoap.org/wsdl/http/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" ><SOAP-ENV:Body><tns:Define xmlns:tns="http://services.aonaware.com/webservices/"><tns:word>bird</tns:word></tns:Define></SOAP-ENV:Body></SOAP-ENV:Envelope>',
  );

  debug_pkg.print (l_xml);

end;

