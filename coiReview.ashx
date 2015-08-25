<%@ WebHandler Language="VB" Class="coiReview" Debug="true" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports System.Data
Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.IO
Imports System.Collections.Generic

Public Class coiReview : Implements IHttpHandler
    
    Dim responses As New List(Of Response)
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
        'j.formID = ""
        
        
        Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
            Using objCmd As New SqlCommand("getCOIForm", objConn)
                objCmd.CommandType = CommandType.StoredProcedure
                objCmd.Parameters.AddWithValue("@formID", j.formID)
                objCmd.Parameters.AddWithValue("@searchCriteria", j.dob)
                If Not objConn.State = ConnectionState.Open Then objConn.Open()
                Using objRdr As SqlDataReader = objCmd.ExecuteReader()
                    objRdr.NextResult() 'don't need the first result set
                    objRdr.NextResult() 'don't need the first result set
                    If objRdr.HasRows Then
                        While objRdr.Read
                            
                                Dim r As New Response
                                ' insert these into a person object
                        
                                r.qnum = objRdr("refNumber").ToString()
                                r.desc = objRdr("conflictDescription").ToString()
                                If r.desc = Nothing Then
                                    r.answer = False
                                Else
                                    r.answer = True
                            End If
                            responses.Add(r)
                        End While
                        
                        
                        'make it JSON flavored and send it back
                        context.Response.Write(SerializeJSON(responses))
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