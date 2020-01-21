VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "PrintIe"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False

Private Const googleUrl As String = "https://google.co.jp"

Private objIE As InternetExplorer
Private objIESel As HTMLSelectElement      'IE�̃Z���N�g�{�b�N�X
Private objIEElm As IHTMLElement           'IE�v�f
Private objIECol As IHTMLElementCollection 'IE�v�f�̃R���N�V����

Public Sub Class_Initialize()
    Sleep 10000
    Set objIE = New InternetExplorer
    objIE.FullScreen = True
End Sub

Public Sub Class_Terminate()
    objIE.Quit
    Set objIE = Nothing
    'IE����邾���ł̓v���Z�X���c��,�����Navigate�Ŏ��s����ꍇ������̂�
    Shell "taskkill /f /im iexplore.exe"
End Sub

'/////////////////////////////////
'// Internet Explorer�Ŏw��̃y�[�W���J��
'/////////////////////////////////
Sub ieView(objIE As InternetExplorer, _
           urlName As String, _
           Optional viewFlg As Boolean = True, _
           Optional ieTop As Integer = 0, _
           Optional ieLeft As Integer = 0, _
           Optional ieWidth As Integer = 600, _
           Optional ieHeight As Integer = 800)

    Set objIE = CreateObject("InternetExplorer.Application")
    With objIE
        .Visible = viewFlg
        .Top = ieTop
        .Left = ieLeft
        .Width = ieWidth
        .Height = ieHeight
        .navigate urlName
    End With
    Call ieCheck(objIE)
    
End Sub

'/////////////////////////////////
'// InternetExplorer�̃y�[�W��
'// ���S�ɕ\�������܂őҋ@����
'/////////////////////////////////
Sub ieCheck(objIE As InternetExplorer)

    Dim timeOut As Date

    '���S�Ƀy�[�W���\�������܂őҋ@����
    timeOut = Now + TimeSerial(0, 0, 20)

    Do While objIE.Busy = True Or objIE.readyState <> 4
        DoEvents
        Sleep 1
        If Now > timeOut Then
            objIE.Refresh
            timeOut = Now + TimeSerial(0, 0, 20)
        End If
    Loop

    timeOut = Now + TimeSerial(0, 0, 20)

    Do While objIE.document.readyState <> "complete"
        DoEvents
        Sleep 1
        If Now > timeOut Then
            objIE.Refresh
            timeOut = Now + TimeSerial(0, 0, 20)
        End If
    Loop

End Sub

'/////////////////////////////////
'// �w��v�f���ɃL�[���[�h�����݂��邩�`�F�b�N����
'/////////////////////////////////
Function tagCheck(objIE As InternetExplorer, _
                 methodType As String, _
                 elementName As String, _
                 keywords As String) As Boolean
 
  Dim objDoc  As Object, myDoc  As Object
  tagCheck = False

  Select Case methodType
    Case "name"
      Set objDoc = objIE.document.getElementsByName(elementName)
    
    Case "class"
      Set objDoc = objIE.document.getElementsByClassName(elementName)
    
    Case "tag"
      Set objDoc = objIE.document.getElementsByTagName(elementName)
  End Select

 
  For Each myDoc In objDoc
    If InStr(myDoc.outerHTML, keywords) > 0 Then
      tagCheck = True
      Exit For
    End If
  Next

End Function

'/////////////////////////////////
'// Google�̌������ʂ��擾����
'/////////////////////////////////

Function GetGoogleResult(serchKeyword As String)
    Call ieView(objIE, googleUrl)
    Set objIEElm = objIE.document.getElementsByName("q")(0)
    objIEElm.Value = serchKeyword
    objIE.document.getElementsByName("btnK")(1).Click
    Sleep 3000
    ' ����V���[�g�J�b�g�L�[���M
    ' SendKeys ("^p")
    objIE.ExecWB OLECMDID_PRINT, OLECMDEXECOPT_DONTPROMPTUSER
    Sleep 5000
    
End Function

Function printPage(filePath As String)
    '����_�C�A���O����
    hWindow = FindWindow("#32770", "���")
    Do While hWindow = 0
        hWindow = FindWindow("#32770", "���")
        Sleep 3000
    Loop
    hButton = FindWindowEx(hWindow, 0, "Button", "���(&P)")

    Call SendMessage(hButton, &H6, 1, 0&)  '�{�^�����A�N�e�B�u�ɂ���
    Call SendMessage(hButton, &HF5, 0, 0&) '�{�^�����N���b�N����

    Sleep 2000
    
    hWindow = FindWindow("#32770", "������ʂ𖼑O��t���ĕۑ�")
    Do While hWindow = 0
        Sleep 3000
        hWindow = FindWindow("#32770", "������ʂ𖼑O��t���ĕۑ�")
    Loop
  
    hInputBox = FindWindowEx(hWindow, 0, "DUIViewWndClassName", "")
    hInputBox = FindWindowEx(hInputBox, 0, "DirectUIHWND", "")
    hInputBox = FindWindowEx(hInputBox, 0, "FloatNotifySink", "")
    hInputBox = FindWindowEx(hInputBox, 0, "ComboBox", "")
    hInputBox = FindWindowEx(hInputBox, 0, "Edit", "")
    hButton = FindWindowEx(hWindow, 0&, "Button", "�ۑ�(&S)")

    Call SendMessage(hInputBox, &HC, 0, filePath)

    Call SendMessage(hButton, &H6, 1, 0&)  '�{�^�����A�N�e�B�u�ɂ���
    Call SendMessage(hButton, &HF5, 0, 0&) '�{�^�����N���b�N����
    Sleep 3000
    
    printPage = filePath
End Function