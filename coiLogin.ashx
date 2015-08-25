<%@ WebHandler Language="VB" Class="coiLogin" debug="true"%>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports System.Data
Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.IO
Imports System.Collections.Generic

Public Class coiLogin : Implements IHttpHandler
    
    Dim e As New CMHAError
     
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        context.Response.ContentType = "text/plain"
        'context.Response.Write((context.Request.HttpMethod).ToString())
        'context.Response.Cookies.Add(New HttpCookie("cmha", "alabastor"))
        'cook = context.Request.Cookies("cmha").Value
        
        Dim myCookie As HttpCookie = New HttpCookie("UserSettings")
        myCookie("Font") = "Arial"
        myCookie("Color") = "Blue"
        myCookie.Expires = Now.AddMinutes(5)
        context.Response.Cookies.Add(myCookie)
        
        Dim json As String = New StreamReader(context.Request.InputStream).ReadToEnd()
        If json = "" Then
            e.errornum = "0"
            e.errortext = "Blank or missing data caused the operation to fail."
            context.Response.Write(SerializeJSON(e))
            Exit Sub
        End If
     
        Dim j As Person = New JavaScriptSerializer().Deserialize(Of Person)(json)
        'j.dob = "12/18/1975"  ' uncomment part above and get rid of this when front-end is linked.
        'j.ssn4 = "1234"
        
        
        Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
            Using objCmd As New SqlCommand("getCOIUserInfo", objConn)
                objCmd.CommandType = CommandType.StoredProcedure
                objCmd.Parameters.AddWithValue("@ssn", j.ssn4)
                objCmd.Parameters.AddWithValue("@dob", j.dob)
                If Not objConn.State = ConnectionState.Open Then objConn.Open()
                Using objRdr As SqlDataReader = objCmd.ExecuteReader()
                    If objRdr.HasRows Then
                        objRdr.Read()
                        Dim p As New Person
                        ' insert these into a person object
                        If objRdr("formID").ToString() <> "" Then
                            p.formID = objRdr("formID").ToString()
                        Else
                            p.formID = ""
                        End If
                        p.employeeID = objRdr("employeeID").ToString()
                        p.fname = objRdr("firstName").ToString()
                        p.lname = objRdr("lastName").ToString()
                        p.title = objRdr("title").ToString()
                        p.address = objRdr("address").ToString()
                        p.suite = objRdr("suite").ToString()
                        p.city = objRdr("city").ToString()
                        p.zip = objRdr("zip").ToString()
                        p.state = objRdr("state").ToString()
                        p.phone = objRdr("phone").ToString()
                        p.dept = objRdr("departmentName").ToString()
                        p.email = objRdr("userName").ToString()
                        p.workAddress = objRdr("workAddress").ToString()
                        p.workPhone = objRdr("phone").ToString()
                        
                        'make it JSON flavored and send it back
                        context.Response.Write(SerializeJSON(p))
                    Else
                        'do not allow entry unless the person is in the HR database
                        e.errornum = "1"
                        e.errortext = "Your date of birth or last four of your SSN is incorrect. Please check your credentials and try again."
                        context.Response.Write(SerializeJSON(e))
                    End If
                End Using
            End Using
        End Using
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class