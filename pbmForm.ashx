<%@ WebHandler Language="VB" Class="pbmForm" debug="true"%>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports System.Data
Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.IO
Imports System.Collections.Generic

Public Class pbmForm : Implements IHttpHandler
    
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
        'j.employeeID = "1000"
        'j.fname = "Rob"
        'j.lname = "Smith"
        'j.email = "email@address.com"
        'j.ssn4 = "1234"
        'j.dob = "12/25/1993"
        'j.supervisor = "Supervisor Smith"
        'j.year = "2016"
     
        Dim formID As String = j.formID
        Dim confirmationNumber As String = j.confirmation
        Dim userID As String = "0"

        If Not j.userID Is Nothing Then userID = j.userID

        'add/update the main form
        If j.formID = "" Then
            Try
                Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
                    Using objCmd As New SqlCommand("insertPBM360Form", objConn)
                        objCmd.CommandType = CommandType.StoredProcedure
                        With objCmd.Parameters
                            .Add("@formID", SqlDbType.Int).Direction = ParameterDirection.Output
                            .Add("@confirmationNumber", SqlDbType.Int).Direction = ParameterDirection.Output
                            .AddWithValue("@employeeID", j.employeeID)
                            .AddWithValue("@firstName", j.fname)
                            .AddWithValue("@lastName", j.lname)
                            .AddWithValue("@emailAddress", j.email)
                            .AddWithValue("@ssn", j.ssn4)
                            .AddWithValue("@dob", j.dob)
                            .AddWithValue("@supervisorName", j.supervisor)
                            .AddWithValue("@formYear", j.year)
                            .AddWithValue("@enteredBy", userID)
                        End With
                        If Not objConn.State = ConnectionState.Open Then objConn.Open()
                        objCmd.ExecuteNonQuery()
                
                        Dim c As New Confirmation
                        c.number = objCmd.Parameters("@confirmationNumber").Value
                        c.formID = objCmd.Parameters("@formID").Value
                        'make it JSON flavored and send it back
                        context.Response.Write(SerializeJSON(c))
                        confirmationNumber = c.number
                    End Using
                End Using
            Catch ex As Exception
                e.errornum = "2"
                e.errortext = "There was an error writing the information to the database. Please try again later or contact the IT department."
                context.Response.Write(SerializeJSON(e))
            End Try
        End If
        
        If j.formID <> "" Then
            Try
                Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
                    Using objCmd As New SqlCommand("updatePBM360Form", objConn)
                        objCmd.CommandType = CommandType.StoredProcedure
                        With objCmd.Parameters
                            .AddWithValue("@formID", j.formID)
                            .Add("@confirmationNumber", SqlDbType.Int).Direction = ParameterDirection.Output
                            .AddWithValue("@employeeID", j.employeeID)
                            .AddWithValue("@firstName", j.fname)
                            .AddWithValue("@lastName", j.lname)
                            .AddWithValue("@supervisorName", j.supervisor)
                            .AddWithValue("@emailAddress", j.email)
                            .AddWithValue("@updatedBy", j.userID)
                            '
                        End With
                        If Not objConn.State = ConnectionState.Open Then objConn.Open()
                        objCmd.ExecuteNonQuery()
                
                        Dim c As New Confirmation
                        c.number = objCmd.Parameters("@confirmationNumber").Value
                        c.formID = objCmd.Parameters("@formID").Value
                        'make it JSON flavored and send it back
                        context.Response.Write(SerializeJSON(c))
                        confirmationNumber = c.number                     
                    End Using
                End Using
            Catch ex As Exception
                e.errornum = "3"
                e.errortext = "There was an error updating the information to the database. Please try again later or contact the IT department."
                context.Response.Write(SerializeJSON(e))
            End Try
        End If

        Dim attachmentFile = ""
        Dim mailBody As String = "<p>Thank you for submitting the online Supervisor/Management Feedback Form. As of " & FormatDate(Now(), DateFormat.ShortDate) & ", your confirmation number is: <span style='font-weight:bold;'>" & confirmationNumber & "</span></p>"
       
        mailBody &= "<p>If you need to make changes to your feedback form before the cutoff period of January 31, " & "2015" & ", you will need to enter your date of birth, last four digits of your SSN, and the confirmation number above.</p>" & _
            "<p>If you have any questions, please feel free to contact the Human Resources Department.</p>" & _
            "<p>Thank you!</p>"
        
        If j.email <> "" Then
            'SendEmail("webmaster@cmha.net", j.email, "ashshaheedz@cmha.net", "", "", " TEST: Conflict of Interest Confirmation", mailBody, attachmentFile, True, Net.Mail.MailPriority.Normal)
            SendEmail("webmaster@cmha.net", "daviess@cmha.net", "", "", "", " TEST: Supervisor/Management Feedback Form Confirmation", mailBody, attachmentFile, True, Net.Mail.MailPriority.Normal)
        Else
            'SendEmail("webmaster@cmha.net", j.email, "ashshaheedz@cmha.net", "", "", " TEST: Conflict of Interest Confirmation", mailBody, attachmentFile, True, Net.Mail.MailPriority.Normal)
            SendEmail("webmaster@cmha.net", "daviess@cmha.net", "", "", "", "TEST: Supervisor/Management Feedback Form missing email address", mailBody, attachmentFile, True, Net.Mail.MailPriority.Normal)
        End If
        
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class