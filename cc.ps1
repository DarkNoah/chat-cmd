
$http_proxy = "http://127.0.0.1:10809"
# $http_proxy = $null
$apiKey = $Env:OPENAI_API_KEY
$baseUrl = "https://api.openai.com/v1/chat/completions"
$input = ""
if ($args.Length -eq 1){
    $input = $args[0]
} else {
    $input = Read-Host "输入你想执行命令的描述"
}


$requestContent = @{
    model = "gpt-3.5-turbo"
    temperature = 0
    messages = @(
        @{
            role= "system"
            content= "请将以下用户输入整理为cmd执行的命令,无需解析直接输出可执行的windows命令"
        },
        @{
            role = "user"
            content = "用户输入: $input"
        }
    )
} | ConvertTo-Json 

$headers = @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type"  = "application/json; charset=utf-8"
}


[array]$params =[System.Text.Encoding]::UTF8.GetBytes($requestContent)

$request = @{
    Method      = "POST"
    Uri         = $baseUrl
    Body        = $params
    Headers = $headers
    Proxy       = $http_proxy
}

$run_cmd = $null
try{
    $response = Invoke-WebRequest @request
    $jsonResponse = $response | ConvertFrom-Json
    foreach ($item in $jsonResponse.choices) {
	$run_cmd = $item.message.content
    }
    $input = Read-Host "Can i run '$run_cmd' ?(Enter to run)"
}catch{
    exit
}



if ($input.Length -eq 0) {
    Invoke-Expression  $run_cmd
}
