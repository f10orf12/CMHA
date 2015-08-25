Imports Microsoft.VisualBasic
Imports System.Web.Script.Serialization
Imports System.Net.Mail

Public Class Form
    Public Property confirmation As String
    Public Property supervisor As String
    Public Property phone As String
    Public Property formID As String
    Public Property employeeID As String
    Public Property fname As String
    Public Property lname As String
    Public Property title As String
    Public Property address As String
    Public Property suite As String
    Public Property city As String
    Public Property state As String
    Public Property zip As String
    Public Property workAddress As String
    Public Property workPhone As String
    Public Property dept As String
    Public Property email As String
    Public Property ssn4 As String
    Public Property dob As String
    Public Property ref0 As String
    Public Property ref1 As String
    Public Property ref2 As String
    Public Property ref3 As String
    Public Property ref4 As String
    Public Property ref5 As String
    Public Property ref6 As String
    Public Property ref7 As String
    Public Property ref8 As String
    Public Property ref9 As String
    Public Property ref10 As String
    Public Property ref11 As String
    Public Property ref12 As String
    Public Property ref13 As String
    Public Property ref14 As String
    Public Property ref15 As String
    Public Property signature As String
    Public Property completedBy As String
    Public Property userID As String
    Public Property addrVerified As Boolean
    Public Property numConflicts As String
    Public Property year As String
End Class

Public Class CMHAError
    Public Property errornum As String
    Public Property errortext As String
End Class

Public Class Confirmation
    Public Property number As String
    Public Property formID As String

End Class

Public Class Conflict
    Public Property formID As String
    Public Property qnum As String
    Public Property desc As String
    Public Property userID As String
End Class

Public Class DDList
    Public Property Locations As List(Of Location)
    Public Property Departments As List(Of Department)
End Class

Public Class Department
    Public Property dID As String
    Public Property deptName As String
    Public Property addr1 As String
    Public Property addr2 As String
    Public Property city As String
    Public Property zip As String
    Public Property phone As String
End Class

Public Class Location
    Public Property lID As String
    Public Property location As String
End Class

Public Class LoginInfo
    Public Property ssn4 As String
    Public Property dob As String
    Public Property year As String
    Public Property number As String
End Class

Public Class Person
    Public Property dob As String
    Public Property ssn4 As String
    Public Property employeeID As String
    Public Property supervisor As String
    Public Property title As String
    Public Property fname As String
    Public Property lname As String
    Public Property address As String
    Public Property city As String
    Public Property state As String
    Public Property zip As String
    Public Property suite As String
    Public Property phone As String
    Public Property dept As String
    Public Property email As String
    Public Property formID As String
    Public Property userID As String
    Public Property year As String
    Public Property workAddress As String
    Public Property workPhone As String
    Public Property confirmation As String
End Class

Public Class Response
    Public Property formID As String
    Public Property qnum As String
    Public Property answer As String
    Public Property desc As String
    Public Property comment As String
End Class

Public Class Question
    Public Property qnum As String
    Public Property qtext As String
End Class

Public Class UseYear
    Public Property year As String
End Class

Public Module Serialize
    Public Function SerializeJSON(ByVal O As Object) As Object
        Dim serializer As New JavaScriptSerializer()
        Dim serializedResult = serializer.Serialize(O)
        Return serializedResult
    End Function
End Module
Public Module intranet
    Public Function FormatDate(ByVal stringToFormat As String, ByVal formatType As DateFormat) As String
        If stringToFormat <> "" Then
            If IsDate(stringToFormat) Then
                stringToFormat = FormatDateTime(stringToFormat, formatType)
            End If
        End If

        Return stringToFormat
    End Function

    Public Function SendEmail(ByVal mailFrom As String, ByVal mailTo As String, ByVal mailCC As String, ByVal mailBCC As String, ByVal mailReplyTo As String, ByVal mailSubject As String, ByVal mailBody As String, ByVal attachments As String, ByVal isHTML As Boolean, ByVal messagePriority As MailPriority) As String
        Dim objMail As New MailMessage
        Dim recipientsTo(), recipientsCC(), recipientsBCC() As String

        Try
            If mailTo.IndexOf(";") > -1 Then
                recipientsTo = mailTo.Split(";")
                For i As Integer = 0 To recipientsTo.Length - 1
                    objMail.To.Add(recipientsTo(i).Trim)
                Next
            Else
                objMail.To.Add(mailTo)
            End If

            If mailCC <> "" Then
                If mailCC.IndexOf(";") > -1 Then
                    recipientsCC = mailCC.Split(";")
                    For i As Integer = 0 To recipientsCC.Length - 1
                        objMail.CC.Add(recipientsCC(i).Trim)
                    Next
                Else
                    objMail.CC.Add(mailCC)
                End If
            Else
                If mailSubject.IndexOf("travel") <> -1 Then
                    objMail.CC.Add("svecd@cmha.net")
                End If
            End If

            If mailBCC <> "" Then
                If mailBCC.IndexOf(";") > -1 Then
                    recipientsBCC = mailBCC.Split(";")
                    For i As Integer = 0 To recipientsBCC.Length - 1
                        objMail.Bcc.Add(recipientsBCC(i).Trim)
                    Next
                Else
                    objMail.Bcc.Add(mailBCC)
                End If
            End If

            If mailReplyTo = "" Then
                mailReplyTo = mailFrom
            End If

            objMail.From = New MailAddress(mailFrom)
            objMail.ReplyToList.Add(mailReplyTo)
            objMail.Subject = mailSubject
            objMail.Body = mailBody
            If attachments <> "" And Not attachments Is Nothing Then
                Dim attachmentFiles() As String = attachments.Split(";")
                For i As Integer = 0 To attachmentFiles.Length - 1
                    If attachmentFiles(i).ToString() <> "" Then
                        objMail.Attachments.Add(New Attachment(attachmentFiles(i)))
                    End If
                Next
            End If
            objMail.IsBodyHtml = isHTML
            objMail.Priority = messagePriority

            Dim sc As New SmtpClient("10.10.222.53")
            sc.Send(objMail)

            Return "OK"
            'HttpContext.Current.Response.Write(objMail.Body)
        Catch ex As Exception
            'HttpContext.Current.Response.Write(ex.Message.ToString)
            Return ex.Message.ToString()
        End Try
    End Function
End Module
