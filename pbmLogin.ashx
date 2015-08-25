<%@ WebHandler Language="VB" Class="pbmLogin" Debug="true" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports System.Data
Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.IO
Imports System.Collections.Generic

Public Class pbmLogin : Implements IHttpHandler
    
    Dim e As New CMHAError
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        context.Response.ContentType = "text/plain"
        
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
        'j.year = "2015"
        
        Try
            Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
                Using objCmd As New SqlCommand("getPBM360UserInfo", objConn)
                    objCmd.CommandType = CommandType.StoredProcedure
                    objCmd.Parameters.AddWithValue("@ssn", j.ssn4)
                    objCmd.Parameters.AddWithValue("@dob", j.dob)
                    objCmd.Parameters.AddWithValue("@formYear", j.year)
                    If Not objConn.State = ConnectionState.Open Then objConn.Open()
                    Using objRdr As SqlDataReader = objCmd.ExecuteReader()
                        If objRdr.HasRows Then
                            objRdr.Read()
                            Dim p As New Person
                            ' insert these into a person object
                            If objRdr("formID").ToString() <> "" Then
                                p.formID = objRdr("formID").ToString()
                                If objRdr("confirmationNumber").ToString() <> "" Then
                                    p.confirmation = objRdr("confirmationNumber").ToString()
                                Else
                                    p.confirmation = ""
                                End If
                            Else
                                p.formID = ""
                            End If
                            p.employeeID = objRdr("employeeID").ToString()
                            p.fname = objRdr("firstName").ToString()
                            p.lname = objRdr("lastName").ToString()
                            p.ssn4 = objRdr("ssn").ToString()
                            p.email = objRdr("emailAddress").ToString()
                            p.dob = objRdr("dob").ToString()
                            p.supervisor = objRdr("supervisorName").ToString()
                       
                        
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
        Catch ex As Exception
            context.Response.Write(ex)
        End Try
       
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class