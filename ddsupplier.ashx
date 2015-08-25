<%@ WebHandler Language="VB" Class="ddsupplier" Debug="true" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports System.Data
Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.IO
Imports System.Collections.Generic

Public Class ddsupplier : Implements IHttpHandler
    Dim locations As New List(Of Location)
    Dim departments As New List(Of Department)
    Dim ddl As New DDList
    Dim e As New CMHAError
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        context.Response.ContentType = "text/plain"
               
        Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
            Using objCmd As New SqlCommand("getLocations", objConn)
                objCmd.CommandType = CommandType.StoredProcedure
                If Not objConn.State = ConnectionState.Open Then objConn.Open()
                Using objRdr As SqlDataReader = objCmd.ExecuteReader()
                    If objRdr.HasRows Then
                        While objRdr.Read
                            Dim l As New Location
                            l.lID = objRdr("locationID").ToString()
                            l.location = objRdr("locationName").ToString()                         
                            locations.Add(l)
                        End While
                    End If
                End Using
            End Using
        End Using
        
        ddl.Locations = locations
        
        Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
            Using objCmd As New SqlCommand("getDepartments", objConn)
                objCmd.CommandType = CommandType.StoredProcedure
                If Not objConn.State = ConnectionState.Open Then objConn.Open()
                Using objRdr As SqlDataReader = objCmd.ExecuteReader()
                    If objRdr.HasRows Then
                        While objRdr.Read
                            Dim d As New Department
                            d.dID = objRdr("departmentID").ToString()
                            d.deptName = objRdr("departmentName").ToString()
                            d.addr1 = objRdr("address").ToString()
                            d.addr2 = objRdr("address2").ToString()
                            d.city = objRdr("city").ToString()
                            d.zip = objRdr("zip").ToString()
                            d.phone = objRdr("phone").ToString()
                            departments.Add(d)                             
                        End While
                    End If
                End Using
            End Using
        End Using
        
        ddl.Departments = departments
        
        context.Response.Write(SerializeJSON(ddl))
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class