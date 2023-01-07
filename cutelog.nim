import std/terminal
import std/strutils
import std/logging

export logging

type
  CuteLogger* = ref object of Logger
    forward: Logger
  CuteLoggerPrefixer* = proc (level: Level): string {.raises: [], noSideEffect.}
  CuteLoggerPainter* = proc (level: Level): CutePalette {.raises: [], noSideEffect.}
  CutePalette* = tuple
    style: set[Style]
    fg: ForegroundColor
    bg: BackgroundColor

type
  CuteConsoleLogger* = ref object of ConsoleLogger
    prefixer: CuteLoggerPrefixer
    painter: CuteLoggerPainter

func emojiPrefix(level: Level): string {.used.} =
  case level:
  of lvlFatal:   # use this level for our most critical outputs
    result = ""  # and don't prefix them with a glyph
  of lvlError:
    result = "💥"
  of lvlWarn:
    result = "⚠️"
  of lvlNotice:
    result = "❌"
  of lvlInfo:
    result = "✔️"
  of lvlDebug:
    result = "🐞"
  of lvlAll, lvlNone:
    discard

method log*(logger: CuteLogger; level: Level; args: varargs[string, `$`]) =
  ## anything that isn't fatal gets a cute emoji
  var
    arguments: seq[string]
  for a in args.items:
    arguments.add a
  when defined(cutelogEmojis):
    let prefix = level.emojiPrefix
  else:
    const prefix = ""
  # separate logging arguments with spaces for convenience
  logger.forward.log(level, prefix & arguments.join(" "))

proc painter*(level: Level): CutePalette =
  result = (style: {}, fg: fgDefault, bg: bgDefault)
  case level:
  of lvlFatal:
    result.fg = fgWhite
  of lvlError:
    result.style.incl styleBright
    result.style.incl styleItalic
    result.fg = fgRed
  of lvlWarn:
    result.style.incl styleBright
    result.fg = fgYellow
  of lvlNotice:
    result.fg = fgCyan
    result.style.incl styleItalic
  of lvlInfo:
    result.fg = fgGreen
  of lvlDebug:
    result.fg = fgBlue
  of lvlAll, lvlNone:
    discard
  when defined(cutelogMonochrome):
    result.fg = fgDefault
    result.bg = bgDefault
  when defined(cutelogBland):
    result.style = {}

# use a lock to avoid thread contention on tty/stderr
when compileOption"threads" and not defined(cutelogNoLock):
  import std/rlocks
  var clobber {.global.}: RLock
  initRLock clobber

  template noclobber*(body: untyped) =
    ## serialize access to the body; usually for output reasons
    withRLock clobber:
      body
else:
  template noclobber*(body: untyped) = body

method log*(logger: CuteConsoleLogger; level: Level; args: varargs[string, `$`]) =
  ## use color and a prefix func to log
  let
    prefix = logger.prefixer(level)
    palette = logger.painter(level)

  template output: untyped =
    if logger.useStderr:
      stderr
    else:
      stdmsg()

  var
    arguments: seq[string]
  for a in args:
    arguments.add a
  var ln: string
  try:
    ln = substituteLog(logger.fmtStr, level, arguments)
  except OsError:  # really...
    ln = arguments.join " "

  template ttyWrap(logic: untyped): untyped {.dirty.} =
    ## setting/resetting terminal styling as necessary
    noclobber:  # use the lock around output
      if output.isatty:
        output.resetAttributes
        output.setForegroundColor(palette.fg,
                                  bright = styleBright in palette.style)
        output.setBackgroundColor(palette.bg,
                                  bright = false)
        output.setStyle(palette.style)
        logic
        output.resetAttributes()
      else:
        logic

  ttyWrap:
    # separate logging arguments with spaces for convenience
    output.writeLine(prefix & ln)

proc newCuteLogger*(console: ConsoleLogger): CuteLogger =
  ## create a new logger instance which forwards to the given console logger
  result = CuteLogger(forward: console)

proc newCuteConsoleLogger*(prefixer: CuteLoggerPrefixer;
                           painter: CuteLoggerPainter;
                           levelThreshold = lvlAll; fmtStr = "";
                           useStderr = true): CuteConsoleLogger =
  result = CuteConsoleLogger(levelThreshold: levelThreshold,
                             prefixer: prefixer, painter: painter,
                             fmtStr: fmtStr, useStderr: useStderr)

proc newCuteConsoleLogger*(levelThreshold = lvlAll; fmtStr = "";
                           useStderr = true): CuteConsoleLogger =
  var
    prefixer: CuteLoggerPrefixer
  when defined(cutelogEmojis):
    prefixer = emojiPrefix
  else:
    prefixer = func (level: Level): string = ""
  result = newCuteConsoleLogger(levelThreshold = levelThreshold, fmtStr = fmtStr,
                                prefixer = prefixer, painter = painter,
                                useStderr = useStderr)
