class Colour
  @Default: new Colour [127, 127, 127, 1.0]
  @Black: new Colour [0, 0, 0, 1.0]
  # @BasePlate: new Colour [32, 32, 32, 1.0]
  # @BasePlateBorder: new Colour [64, 64, 64, 1.0]

  @BasePlate: new Colour [32, 32, 32, 1.0]
  @BasePlateBorder: new Colour [64, 64, 64, 1.0]


  @Town: new Colour [0, 127, 255, 1.0]
  @Route: new Colour [127, 63, 0, 1.0]
  @Instance: new Colour [0, 255, 127, 1.0]
  @Obstacle: new Colour [220, 64, 12, 1.0]

  @Path: new Colour [63, 127, 63, 1.0]
  @RouteLink: new Colour [63, 31, 0, 1.0]
  constructor: ([@r,@g,@b,@a]) ->
    @a = 1.0 unless @a
  
  rgba: () -> "rgba(#{@r},#{@g},#{@b},#{@a})"

window.Colour = Colour