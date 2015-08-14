# 本程序用于清理目录保存的文件，每个域只保存最新5个版本
#
# 目录结构示例 /home/upload/deployset_xxxxxxxx/域名/版本号

require 'fileutils'

require "logger"
logger = Logger.new('/apps/logs/cron/clearFtpTar.log', 10, 1024000)
logger.level = Logger::INFO

# version保留数量
LIMIT_COUNT = 5

# 首层目录
firstDir = "/home/upload/"

logger.info "start running ..."

Dir.foreach(firstDir) do |file|
	secondDir = firstDir + file
	if(file.index("deployset_")==0 && File.ftype(secondDir)=="directory")

		Dir.foreach(secondDir) do |file2|
			thirdDir = secondDir + "/" + file2
			if(file2!="." && file2!=".." && File.ftype(thirdDir)=="directory")

				versions = Dir.entries(thirdDir) - [".",".."]
				if(versions.length > LIMIT_COUNT)
					vs = [] # int数组，用于排序
					versions.each do |d|
						vs.push(d.to_i)
					end
					vs.sort! #重新排序
					deleteCount = vs.length - LIMIT_COUNT
					currentCount = 0
					logger.info "=================================="
					logger.info vs
					while currentCount < deleteCount
						FileUtils.rm_rf(thirdDir + "/" + vs[currentCount].to_s)
						logger.info "delete " + thirdDir + "/" + vs[currentCount].to_s
						currentCount = currentCount + 1
					end
				else
					# logger.info thirdDir + " length is:" + versions.length.to_s
				end

			end
		end
	end
end

logger.info "finish running ..."