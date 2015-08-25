<%@ WebHandler Language="VB" Class="coiFormUpdate" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports System.Data
Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.IO
Imports System.Collections.Generic

Public Class coiFormUpdate : Implements IHttpHandler
    
    Dim e As New CMHAError
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        context.Response.ContentType = "text/plain"
        
        Dim json As String = New StreamReader(context.Request.InputStream).ReadToEnd()
        'context.Response.Write(json)
        If json = "" Then
            'e.errornum = "0"
            'e.errortext = "Blank or missing data caused the operation to fail."
            'context.Response.Write(SerializeJSON(e))
            'Exit Sub
        End If
        
        Dim j As Form = New JavaScriptSerializer().Deserialize(Of Form)(json)
        
        Dim formID As String = j.formID
        Dim confirmationNumber As String = ""
        'Dim sqlQuery As String = "insertCOIForm"
        Dim sqlQueryConflict As String = "insertCOIConflict"
        Dim userID As String = "0"
        Dim numberOfConflicts As Integer = 0

        If Not j.userID Is Nothing Then userID = j.userID

        'add/update the main form
        If j.formID = "" Then
            
        End If
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class