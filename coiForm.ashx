<%@ WebHandler Language="VB" Class="coiForm" Debug="true" %>

Imports System
Imports System.Web
Imports System.Web.Script.Serialization
Imports System.Data
Imports System.Data.Sql
Imports System.Data.SqlClient
Imports System.IO
Imports System.Collections.Generic

Public Class coiForm : Implements IHttpHandler
    
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
        
        Dim j As Form  = New JavaScriptSerializer().Deserialize(Of Form)(json)
        'j.ssn4 = "1234"
        'j.dob = "12/18/1975"
        'j.formID = "1872"
        'j.employeeID = "1000"
        'j.fname = "steve"
        'j.lname = "davies"
        'j.dept = "my house"
        'j.userID = "422"
        'j.workPhone = "123-045-7890"
        'j.year = "2016"
        'j.zip = "12345"
        'j.title = "bozo"
        'j.address = "123 street"
        'j.city = "canton"
        'j.state = "ohio"
        'j.suite = "2"
        'j.workAddress = "123 street"
        'j.email = "happyfeet"
        'j.ref0 = False
        'j.ref1 = False
        'j.ref2 = False
        'j.ref3 = False
        'j.ref4 = False
        'j.ref5 = False
        'j.ref6 = False
        'j.ref7 = False
        'j.ref8 = False
        'j.ref9 = False
        'j.ref10 = False
        'j.ref11 = False
        'j.ref12 = False
        'j.ref13 = False
        'j.ref14 = False
        'j.ref15 = False
        'j.signature = "steve"
        
        'j.addrVerified = True
        'j.address = "123 Anywhere Lane"
        'j.city = "Cleveland"
        'j.completedBy = ""
        'j.dept = "AMPs - Carver Park"
        'j.dob = "12/18/1975"
        'j.email = "daviess@cmha.net"
        'j.employeeID = "1000"
        'j.fname = "Sample"
        'j.formID = ""
        'j.lname = "User"
        'j.numConflicts = 1
       
        'j.phone = "(216) 348-1393"
        'j.ref0 = True
        'j.ref1 = False
        'j.ref2 = False
        'j.ref3 = False
        'j.ref4 = False
        'j.ref5 = False
        'j.ref6 = False
        'j.ref7 = False
        'j.ref8 = False
        'j.ref9 = False
        'j.ref10 = False
        'j.ref11 = False
        'j.ref12 = False
        'j.ref13 = False
        'j.ref14 = False
        'j.ref15 = False
        'j.signature = "Sample User"
        'j.ssn4 = "1234"
        'j.state = "OH"
        'j.suite = " "
       
        'j.title = "Quality Assurance Specialist"
        
       
        'j.workAddress = "8120 Kinsman Road, Cleveland, OH 44104"
       
        'j.workPhone = "(216) 348-5000"
        'j.year = 2015
        'j.zip = "44109"

        
        Dim formID As String = j.formID
        Dim confirmationNumber As String = ""
        Dim userID As String = "0"
        Dim numberOfConflicts As Integer = j.numConflicts

        If Not j.userID Is Nothing Then userID = j.userID

        'add/update the main form
        If j.formID = "" Then
            Try
                Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
                    Using objCmd As New SqlCommand("insertCOIForm", objConn)
                        objCmd.CommandType = CommandType.StoredProcedure
                        'objCmd.Parameters.Add("@userName", SqlDbType.VarChar, 32).Value = j.userID
                        With (objCmd.Parameters)
                            .Add("@formID", SqlDbType.Int).Direction = ParameterDirection.Output
                            .Add("@confirmationNumber", SqlDbType.Int).Direction = ParameterDirection.Output
                            .Add("@employeeID", SqlDbType.Int).Value = j.employeeID
                            .Add("@firstName", SqlDbType.VarChar, 255).Value = j.fname
                            .Add("@lastName", SqlDbType.VarChar, 255).Value = j.lname
                            .Add("@jobTitle", SqlDbType.VarChar, 255).Value = j.title
                            .Add("@address", SqlDbType.VarChar, 255).Value = j.address
                            .Add("@suite", SqlDbType.VarChar, 255).Value = j.suite
                            .Add("@city", SqlDbType.VarChar, 255).Value = j.city
                            .Add("@state", SqlDbType.VarChar, 255).Value = j.state
                            .Add("@zip", SqlDbType.Int).Value = j.zip
                            .Add("@addressVerified", SqlDbType.Bit).Value = j.addrVerified
                            .Add("@workAddress", SqlDbType.VarChar, 255).Value = j.workAddress
                            .Add("@workPhone", SqlDbType.VarChar, 255).Value = j.workPhone
                            .Add("@department", SqlDbType.VarChar, 255).Value = j.dept
                            .Add("@emailAddress", SqlDbType.VarChar, 255).Value = j.email
                            .Add("@ssn", SqlDbType.VarChar, 4).Value = j.ssn4
                            .Add("@dob", SqlDbType.Date).Value = j.dob
                            .Add("@ref1", SqlDbType.Bit).Value = j.ref0
                            .Add("@ref2", SqlDbType.Bit).Value = j.ref1
                            .Add("@ref3", SqlDbType.Bit).Value = j.ref2
                            .Add("@ref4", SqlDbType.Bit).Value = j.ref3
                            .Add("@ref5", SqlDbType.Bit).Value = j.ref4
                            .Add("@ref6", SqlDbType.Bit).Value = j.ref5
                            .Add("@ref7", SqlDbType.Bit).Value = j.ref6
                            .Add("@ref8", SqlDbType.Bit).Value = j.ref7
                            .Add("@ref9", SqlDbType.Bit).Value = j.ref8
                            .Add("@ref10", SqlDbType.Bit).Value = j.ref9
                            .Add("@ref11", SqlDbType.Bit).Value = j.ref10
                            .Add("@ref12", SqlDbType.Bit).Value = j.ref11
                            .Add("@ref13", SqlDbType.Bit).Value = j.ref12
                            .Add("@ref14", SqlDbType.Bit).Value = j.ref13
                            .Add("@ref15", SqlDbType.Bit).Value = j.ref14
                            .Add("@ref16", SqlDbType.Bit).Value = j.ref15
                            .Add("@signature", SqlDbType.VarChar, 255).Value = j.signature
                            .Add("@completedBy", SqlDbType.Int).Value = userID
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
                Exit Sub
            End Try
        End If
        
        If j.formID <> "" Then
            Try
                Using objConn As New SqlConnection(ConfigurationManager.ConnectionStrings("objConn").ConnectionString)
                    Using objCmd As New SqlCommand("updateCOIForm", objConn)
                        objCmd.CommandType = CommandType.StoredProcedure
                        With objCmd.Parameters
                            .Add("@formID", SqlDbType.Int).Value = j.formID
                            .Add("@confirmationNumber", SqlDbType.Int).Direction = ParameterDirection.Output
                            .Add("@employeeID", SqlDbType.Int).Value = j.employeeID
                            .Add("@firstName", SqlDbType.VarChar, 255).Value = j.fname
                            .Add("@lastName", SqlDbType.VarChar, 255).Value = j.lname
                            .Add("@jobTitle", SqlDbType.VarChar, 255).Value = j.title
                            .Add("@address", SqlDbType.VarChar, 255).Value = j.address
                            .Add("@suite", SqlDbType.VarChar, 50).Value = j.suite
                            .Add("@city", SqlDbType.VarChar, 50).Value = j.city
                            .Add("@state", SqlDbType.VarChar, 50).Value = j.state
                            .Add("@zip", SqlDbType.Int).Value = j.zip
                            .Add("@addressVerified", SqlDbType.Int).Value = j.addrVerified
                            .Add("@workAddress", SqlDbType.VarChar, 255).Value = j.workAddress
                            .Add("@workPhone", SqlDbType.VarChar, 50).Value = j.workPhone
                            .Add("@department", SqlDbType.VarChar, 255).Value = j.dept
                            .Add("@emailAddress", SqlDbType.VarChar, 255).Value = j.email
                            '.Add("@ssn", SqlDbType.VarChar, 4).Value = j.ssn4
                            '.Add("@dob", SqlDbType.Date).Value = j.dob
                            .Add("@ref1", SqlDbType.Bit).Value = j.ref0
                            .Add("@ref2", SqlDbType.Bit).Value = j.ref1
                            .Add("@ref3", SqlDbType.Bit).Value = j.ref2
                            .Add("@ref4", SqlDbType.Bit).Value = j.ref3
                            .Add("@ref5", SqlDbType.Bit).Value = j.ref4
                            .Add("@ref6", SqlDbType.Bit).Value = j.ref5
                            .Add("@ref7", SqlDbType.Bit).Value = j.ref6
                            .Add("@ref8", SqlDbType.Bit).Value = j.ref7
                            .Add("@ref9", SqlDbType.Bit).Value = j.ref8
                            .Add("@ref10", SqlDbType.Bit).Value = j.ref9
                            .Add("@ref11", SqlDbType.Bit).Value = j.ref10
                            .Add("@ref12", SqlDbType.Bit).Value = j.ref11
                            .Add("@ref13", SqlDbType.Bit).Value = j.ref12
                            .Add("@ref14", SqlDbType.Bit).Value = j.ref13
                            .Add("@ref15", SqlDbType.Bit).Value = j.ref14
                            .Add("@ref16", SqlDbType.Bit).Value = j.ref15
                            .Add("@signature", SqlDbType.VarChar, 50).Value = j.signature
                            .Add("@letterConflict", SqlDbType.Bit).Value = 0
                            .Add("@letterConflictSent", SqlDbType.Date).Value = "12/18/2000"
                            .Add("@letterConflictScanned", SqlDbType.Bit).Value = 0
                            .Add("@letterConflictScanLocation", SqlDbType.VarChar, 500).Value = ""
                            .Add("@letterNoConflict", SqlDbType.Bit).Value = 0
                            .Add("@letterNoConflictSent", SqlDbType.Date).Value = "12/18/2000"
                            .Add("@letterNoConflictScanned", SqlDbType.Bit).Value = 0
                            .Add("@letterNoConflictScanLocation", SqlDbType.VarChar, 500).Value = ""
                            .Add("@isAdmin", SqlDbType.VarChar, 50).Value = ""
                            .Add("@updatedBy", SqlDbType.Int).Value = userID
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
                Throw ex
                e.errornum = "3"
                e.errortext = "There was an error updating the information to the database. Please try again later or contact the IT department."
                'Exit Sub
            End Try
        End If
        
        
        Dim attachmentFile = ""
        Dim mailBody As String = "<p>Thank you for submitting the online Conflict of Interest Disclosure form as of " & FormatDate(Now(), DateFormat.ShortDate) & " disclosure date. Your confirmation number is: <span style='font-weight:bold;'>" & confirmationNumber & "</span></p>"
        If numberOfConflicts = 0 Then
            mailBody &= "You answered <span style='font-weight:bold;text-decoration:underline;'>NO</span> to all 16 questions on the Conflict of Interest Disclosure form. Based on your self-disclosure, Compliance has determined that no further review is necessary." & _
                "<p>Please be advised that your responses are subject to random quality control review to verify the validity of the information you have provided.</p>"
        Else
            mailBody &= "You answered <span style='font-weight:bold;text-decoration:underline;'>YES</span> to " & numberOfConflicts & " question(s) on the Conflict of Interest Disclosure form.  Your response(s) indicate a potential conflict of interest. These response(s) will be reviewed by Compliance and a determination will be made if a conflict of interest exists. You will be notified of the result of this review by the Compliance Department."
        End If
        mailBody &= "<p>If you need to make changes to your disclosure form before the cutoff period of January 31, " & "2015" & ", you will need to enter your date of birth, last four digits of your SSN, and the confirmation number above.</p>" & _
            "<p>If there are any changes after the end of the disclosure period, you will need to complete an updated conflict of interest disclosure form which can be obtained from the Compliance Department or found on the Intranet at Departments > Compliance > Conflict of Interest Forms > Conflict of Interest Employee Questionnaire and Verification Form." & _
            "<p>If you have any questions, please feel free to contact the Compliance Department at 216-271-2442.</p>" & _
            "<p>Thank you!</p>"
        
        If j.email <> "" Then
            'SendEmail("webmaster@cmha.net", j.email, "ashshaheedz@cmha.net", "", "", " TEST: Conflict of Interest Confirmation", mailBody, attachmentFile, True, Net.Mail.MailPriority.Normal)
            SendEmail("webmaster@cmha.net", j.email, "", "", "", " TEST: Conflict of Interest Confirmation", mailBody, attachmentFile, True, Net.Mail.MailPriority.Normal)
        Else
            'SendEmail("webmaster@cmha.net", j.email, "ashshaheedz@cmha.net", "", "", " TEST: Conflict of Interest Confirmation", mailBody, attachmentFile, True, Net.Mail.MailPriority.Normal)
            SendEmail("webmaster@cmha.net", "daviess@cmha.net", "", "", "", "TEST: Conflict of Interest Confirmation missing email address", mailBody, attachmentFile, True, Net.Mail.MailPriority.Normal)
        End If
        
   
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class