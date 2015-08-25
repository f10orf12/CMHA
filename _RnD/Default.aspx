<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="_RnD_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../scripts/jquery-2.1.4.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(document).on('ready', function () {
            $('#pwdConfirmer').on('keypress', function (e) {
                var a = $.trim($('.pswdconfirm').val());
                var b = $.trim($('.pswd').val());
                if (b.length < 1) { a = '' }
                console.log('a: ', a);
            });
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:TextBox CssClass="pswd" ID="pwd" TextMode="Password" runat="server" Text=""
            ClientIDMode="Static" />
        <asp:TextBox CssClass="pswdconfirm" ID="pwdConfirmer" TextMode="Password" runat="server"
            Text="" ClientIDMode="Static" />
    </div>
    </form>
</body>
</html>
