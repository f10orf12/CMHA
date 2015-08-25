<%@ WebHandler Language="VB" Class="pbmReview" Debug="true" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports System.Data
Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.IO
Imports System.Collections.Generic

Public Class pbmReview : Implements IHttpHandler
    
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
     
        Dim j As LoginInfo = New JavaScriptSerializer().Deserialize(Of LoginInfo)(json)
        'j.dob = "12/25/1993"  ' uncomment part above and get rid of this when front-end is linked.
        'j.ssn4 = "4591"
        'j.confirmation = "73341801"
        'j.formID = ""
        Try
            Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
                Using objCmd As New SqlCommand("getPBM360Form", objConn)
                    objCmd.CommandType = CommandType.StoredProcedure
                    objCmd.Parameters.AddWithValue("@formID", "")
                    objCmd.Parameters.AddWithValue("@searchCriteria", j.number)
                    If Not objConn.State = ConnectionState.Open Then objConn.Open()
                    Using objRdr As SqlDataReader = objCmd.ExecuteReader()
                        objRdr.NextResult() 'don't need the first result set
                        If objRdr.HasRows Then
                            While objRdr.Read
                            
                                Dim r As New Response
                                ' insert these into a person object
                                r.formID = objRdr("formID").ToString()
                                r.qnum = objRdr("questionNumber").ToString()
                                r.desc = objRdr("questionText").ToString()
                                r.answer = objRdr("questionResponse").ToString()
                                r.comment = objRdr("questionComment").ToString()
                                responses.Add(r)
                            End While
                        
                        
                            'make it JSON flavored and send it back
                            context.Response.Write(SerializeJSON(responses))
                        Else
                            'do not allow entry unless the person is in the HR database
                            e.errornum = "7"
                            e.errortext = "There was an error retrieving your information from the database. Please contact the Information Technology department."
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