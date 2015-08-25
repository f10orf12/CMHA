<%@ WebHandler Language="VB" Class="pbm" debug="true"%>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports System.Data
Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.IO
Imports System.Collections.Generic

Public Class pbm : Implements IHttpHandler
    
    Dim questions As New List(Of Question)
    Dim e As New CMHAError
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        
        'Dim json As String = New StreamReader(context.Request.InputStream).ReadToEnd()
        
        'If json = "" Then
        '    e.errornum = "0"
        '    e.errortext = "Blank or missing data caused the operation to fail."
        '    context.Response.Write(SerializeJSON(e))
        '    Exit Sub
        'End If
        
        Dim y As New UseYear' = New JavaScriptSerializer().Deserialize(Of UseYear)(json)
        y.year = 2015
        Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
            Using objCmd As New SqlCommand("getPBM360Questions", objConn)
                objCmd.CommandType = CommandType.StoredProcedure
                objCmd.Parameters.AddWithValue("@formYear", y.year)
                If Not objConn.State = ConnectionState.Open Then objConn.Open()
                Using objRdr As SqlDataReader = objCmd.ExecuteReader()
                    If objRdr.HasRows Then
                        While objRdr.Read
                            Dim q As New Question
                            q.qnum = objRdr("questionNumber").ToString()
                            q.qtext = objRdr("questionText").ToString()
                            
                            questions.Add(q)
                                                        
                        End While
                    End If
                End Using
            End Using
        End Using   

        context.Response.Write(SerializeJSON(questions))

    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class