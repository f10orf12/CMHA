<%@ WebHandler Language="VB" Class="pbmResponses" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports System.Data
Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.IO
Imports System.Collections.Generic

Public Class pbmResponses : Implements IHttpHandler
    
    Dim e As New CMHAError
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        context.Response.ContentType = "text/plain"
        
        Dim json As String = New StreamReader(context.Request.InputStream).ReadToEnd()
        'context.Response.Write(json)
        If json = "" Then
            e.errornum = "0"
            e.errortext = "Blank or missing data caused the operation to fail."
            context.Response.Write(SerializeJSON(e))
            Exit Sub
        End If
        
        Dim responses As Generic.List(Of Response) = New JavaScriptSerializer().Deserialize(Of List(Of Response))(json)
        

        Try   
            Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
                Using objCmd As New SqlCommand("insertPBM360FormResponses", objConn)
                    objCmd.CommandType = CommandType.StoredProcedure
                    With objCmd.Parameters
                        For Each r As Response In responses
                            .AddWithValue("@formID", r.formID)
                            .AddWithValue("@questionNumber", r.qnum)
                            .AddWithValue("@questionText", r.desc)
                            .AddWithValue("@questionResponse", r.answer)
                            .AddWithValue("@questionComment", r.comment)
                            If Not objConn.State = ConnectionState.Open Then objConn.Open()
                            objCmd.ExecuteNonQuery()
                            objCmd.Parameters.Clear()
                        
                        Next
                    End With
                    context.Response.Write(SerializeJSON("success"))
                End Using
            End Using
        Catch ex As Exception
            context.Response.Write(ex)
            e.errornum = "2"
            e.errortext = "There was an error writing the information to the database. Please try again later or contact the IT department."
            context.Response.Write(SerializeJSON(e))
        End Try
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class