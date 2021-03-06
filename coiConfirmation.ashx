﻿<%@ WebHandler Language="VB" Class="coiConfirmation" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports System.Data
Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.IO
Imports System.Collections.Generic

Public Class coiConfirmation : Implements IHttpHandler
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
        'j.year = "2015"
        
        
        Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
            Using objCmd As New SqlCommand("getCOIConfirmationNumberByDOBAndSSN", objConn)
                objCmd.CommandType = CommandType.StoredProcedure
                objCmd.Parameters.AddWithValue("@ssn", j.ssn4)
                objCmd.Parameters.AddWithValue("@dob", j.dob)
                objCmd.Parameters.AddWithValue("@coiYear", j.year)
                If Not objConn.State = ConnectionState.Open Then objConn.Open()
                Using objRdr As SqlDataReader = objCmd.ExecuteReader()
                    If objRdr.HasRows Then
                        objRdr.Read()
                        Dim l As New LoginInfo
                        ' insert these into a person object
                        l.number = objRdr("confirmationNumber").ToString()
                        l.dob = j.dob
                        l.ssn4 = j.ssn4
                        l.year = j.year
                        'make it JSON flavored and send it back
                        context.Response.Write(SerializeJSON(l))
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