load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("xpath.star", "xpath")

def main(config):
    rss_content = http.get(
        config.get("feed", "https://feeds.arstechnica.com/arstechnica/index"),
        ttl_seconds = 300,
    ).body()

    # Get the header based on the channel title and put it into a marquee for scrolling - it's too wide to display
    header = render.Box(
        render.Marquee(
            child = render.Text(
                xpath.loads(rss_content).query("/rss/channel/title"),
                color = "#e39600",
                font = "tom-thumb",
            ),
            width = 64,
        ),
        width = 64,
        height = 6,
        color = "#ffffff80",
    )

    # Get the latest news item node and record the article title. Put it into a vertical marquee.
    latest_item = xpath.loads(rss_content).query_node("/rss/channel/item")
    most_recent = latest_item.query("/title")
    body = render.Marquee(
        child = render.WrappedText(most_recent, font = "tom-thumb"),
        scroll_direction = "vertical",
        width = 64,
        height = 26,
    )

    # Get the article image for use as a background if available
    image_http = http.get(latest_item.query("/media:content/@url"), ttl_seconds = 3600).body()
    image_render = None
    if image_http != None and len(image_http) > 0:
        image_render = render.Image(
            src = http.get(latest_item.query("/media:content/@url")).body(),
            width = 64,
            height = 32,
        )

    # Some debug prints
    # print(xpath.loads(rss_content).query('/rss/channel/title'))
    # print(most_recent)

    # Put the text content into a single column widget
    render_text = render.Column(
        children = [
            header,
            body,
        ],
        main_align = "start",
        cross_align = "center",
        expanded = True,
    )

    # Stack the text content on top of the background image
    render_panel = render.Stack(
        children = [
            image_render,
            render_text,
        ],
    )

    return render.Root(
        child = render_panel,
        show_full_animation = True,
    )

def get_schema():
    options = [
        schema.Option(
            display = "All News: Every article from every section of the site",
            value = "https://feeds.arstechnica.com/arstechnica/index",
        ),
        schema.Option(
            display = "Ars Features: All our long-form feature articles",
            value = "https://feeds.arstechnica.com/arstechnica/features",
        ),
        schema.Option(
            display = "Technology Lab: Information Technology",
            value = "https://feeds.arstechnica.com/arstechnica/technology-lab",
        ),
        schema.Option(
            display = "Gear & Gadgets: Product News & Reviews",
            value = "https://feeds.arstechnica.com/arstechnica/gadgets",
        ),
        schema.Option(
            display = "Law & Disorder: Civilization & Discontents",
            value = "https://feeds.arstechnica.com/arstechnica/tech-policy",
        ),
        schema.Option(
            display = "Infinite Loop: The Apple Ecosystem",
            value = "https://feeds.arstechnica.com/arstechnica/apple",
        ),
        schema.Option(
            display = "Opposable Thumbs: Gaming & Entertainment",
            value = "https://feeds.arstechnica.com/arstechnica/gaming",
        ),
        schema.Option(
            display = "The Scientific Method: Science & Exploration",
            value = "https://feeds.arstechnica.com/arstechnica/science",
        ),
        schema.Option(
            display = "Cars Technica: All Things Automotive",
            value = "https://feeds.arstechnica.com/arstechnica/cars",
        ),
        schema.Option(
            display = "Staff Blogs: From the Minds of Ars",
            value = "https://feeds.arstechnica.com/arstechnica/staff-blogs",
        ),
        schema.Option(
            display = "Ars Cardboard: Board Games News & Reviews",
            value = "https://feeds.arstechnica.com/arstechnica/cardboard",
        ),
    ]
    return schema.Schema(
        version = "1",
        fields = [
            schema.Dropdown(
                id = "feed",
                name = "Ars Section Feed",
                desc = "The section or main feed to display",
                icon = "brush",
                default = options[0].value,
                options = options,
            ),
        ],
    )
