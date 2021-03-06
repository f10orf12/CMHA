﻿<%@ WebHandler Language="VB" Class="coiConflict" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports System.Data
Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.IO
Imports System.Collections.Generic

Public Class coiConflict : Implements IHttpHandler
    
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

        Dim conflicts As Generic.List(Of Conflict) = New JavaScriptSerializer().Deserialize(Of List(Of Conflict))(json)
             
        'add/update the main form
        Try
            Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
                Using objCmd As New SqlCommand("insertCOIConflict", objConn)
                    objCmd.CommandType = CommandType.StoredProcedure
                    With objCmd.Parameters
                        
                        For Each c As Conflict In conflicts
                            .AddWithValue("@formID", c.formID)
                            .AddWithValue("@refNumber", c.qnum)
                            .AddWithValue("@conflictDescription", c.desc)
                            If Not objConn.State = ConnectionState.Open Then objConn.Open()
                            objCmd.ExecuteNonQuery()
                            objCmd.Parameters.Clear()
                        
                        Next
                        
                    End With
                    context.Response.Write(SerializeJSON("success"))
                End Using
            End Using
        Catch ex As Exception
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