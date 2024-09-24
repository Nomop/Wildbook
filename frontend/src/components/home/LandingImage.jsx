import React from "react";

export default function Header() {
  return (
    <div
      className="position-relative overflow-hidden"
      style={{
        height: "500px",
        backgroundImage: `url('/react/images/forest.png')`,
        backgroundSize: "cover",
        backgroundPosition: "center",
        backgroundRepeat: "no-repeat",
      }}
    >
      <div
        className="position-absolute"
        style={{
          top: "-180px",
          left: "-50px",
        }}
      >
        <svg
          width="673"
          height="955"
          viewBox="0 0 773 955"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <g filter="url(#filter0_b_2249_3810)">
            <path
              fillRule="evenodd"
              clipRule="evenodd"
              d="M0 0H422V446.65H392.612V341.037H366.362V468H422V493.138C419.089 492.804 416.09 492.637 413.003 492.637C403.261 492.637 394.394 494.3 386.403 497.625C378.411 500.892 371.557 505.412 365.84 511.187C360.123 516.962 355.69 523.817 352.54 531.75C349.448 539.625 347.903 548.2 347.903 557.475C347.903 566.75 349.448 575.354 352.54 583.287C355.69 591.221 360.123 598.075 365.84 603.85C371.557 609.625 378.411 614.175 386.403 617.5C394.394 620.767 403.261 622.4 413.003 622.4C416.09 622.4 419.089 622.236 422 621.908V955H0V0ZM413.003 514.688C416.185 514.688 419.184 514.971 422 515.539V599.436C419.184 599.987 416.185 600.263 413.003 600.263C407.053 600.263 401.715 599.3 396.99 597.375C392.265 595.392 388.24 592.562 384.915 588.888C381.648 585.213 379.14 580.75 377.39 575.5C375.64 570.192 374.765 564.183 374.765 557.475C374.765 550.825 375.64 544.875 377.39 539.625C379.14 534.317 381.648 529.825 384.915 526.15C388.24 522.417 392.265 519.587 396.99 517.662C401.715 515.679 407.053 514.688 413.003 514.688ZM288.038 600.875C292.238 600.875 295.679 600.379 298.363 599.388C301.104 598.338 303.292 596.967 304.925 595.275C306.558 593.583 307.696 591.658 308.338 589.5C308.979 587.283 309.3 585.008 309.3 582.675C309.3 580.108 308.921 577.804 308.163 575.763C307.404 573.721 306.179 572 304.488 570.6C302.796 569.142 300.579 568.033 297.838 567.275C295.154 566.517 291.829 566.138 287.863 566.138H265.55V600.875H288.038ZM265.55 513.987V548.287H282.788C286.462 548.287 289.729 547.996 292.587 547.412C295.446 546.771 297.838 545.779 299.763 544.438C301.688 543.096 303.146 541.346 304.138 539.188C305.188 536.971 305.713 534.317 305.713 531.225C305.713 528.075 305.275 525.392 304.4 523.175C303.583 520.958 302.3 519.179 300.55 517.837C298.8 516.496 296.583 515.533 293.9 514.95C291.217 514.308 288.038 513.987 284.363 513.987H265.55ZM284.363 494.037C292.879 494.037 300.142 494.854 306.15 496.487C312.217 498.062 317.146 500.337 320.938 503.312C324.788 506.229 327.588 509.787 329.338 513.987C331.088 518.188 331.963 522.883 331.963 528.075C331.963 530.992 331.525 533.792 330.65 536.475C329.833 539.158 328.521 541.696 326.713 544.087C324.963 546.421 322.688 548.55 319.888 550.475C317.088 552.4 313.763 554.033 309.913 555.375C318.546 557.417 324.933 560.742 329.075 565.35C333.217 569.958 335.288 575.938 335.288 583.287C335.288 588.654 334.238 593.642 332.138 598.25C330.096 602.858 327.092 606.854 323.125 610.237C319.158 613.621 314.258 616.275 308.425 618.2C302.65 620.067 296 621 288.475 621H239.3V494.037H284.363ZM259.725 468L299.1 341.037H278.45C276.233 341.037 274.338 341.621 272.763 342.787C271.188 343.954 270.196 345.296 269.788 346.812L250.1 418.387C249.633 420.254 249.167 422.296 248.7 424.512C248.292 426.671 247.854 428.975 247.388 431.425C246.863 428.975 246.308 426.671 245.725 424.512C245.142 422.296 244.5 420.254 243.8 418.387L220.963 346.812C220.263 345.121 219.183 343.75 217.725 342.7C216.325 341.592 214.488 341.037 212.213 341.037H204.513C202.296 341.037 200.4 341.65 198.825 342.875C197.308 344.042 196.317 345.354 195.85 346.812L172.925 418.387C172.225 420.371 171.583 422.5 171 424.775C170.417 427.05 169.863 429.5 169.338 432.125C168.871 429.558 168.375 427.137 167.85 424.862C167.383 422.529 166.917 420.371 166.45 418.387L146.762 346.812C146.296 345.062 145.275 343.662 143.7 342.612C142.183 341.562 140.288 341.037 138.012 341.037H115.963L155.25 468H179.05L205.3 384.962C205.708 383.796 206.117 382.512 206.525 381.112C206.933 379.712 207.313 378.225 207.663 376.65C208.013 378.225 208.392 379.712 208.8 381.112C209.208 382.512 209.617 383.796 210.025 384.962L236.013 468H259.725ZM313.383 468H339.808V341.037H313.383V468Z"
              fill="#F4F5C7"
              fillOpacity="0.3"
            />
          </g>
          <g clipPath="url(#clip0_2249_3810)">
            <path
              d="M549.138 404.475C549.138 413.75 547.563 422.296 544.413 430.112C541.321 437.871 536.917 444.55 531.2 450.15C525.542 455.75 518.717 460.125 510.725 463.275C502.733 466.425 493.867 468 484.125 468H435.3V341.037H484.125C493.867 341.037 502.733 342.612 510.725 345.762C518.717 348.912 525.542 353.317 531.2 358.975C536.917 364.575 541.321 371.254 544.413 379.012C547.563 386.771 549.138 395.258 549.138 404.475ZM522.188 404.475C522.188 397.825 521.313 391.846 519.563 386.537C517.813 381.229 515.304 376.737 512.038 373.062C508.771 369.387 504.775 366.558 500.05 364.575C495.383 362.592 490.075 361.6 484.125 361.6H461.725V447.437H484.125C490.075 447.437 495.383 446.475 500.05 444.55C504.775 442.567 508.771 439.737 512.038 436.062C515.304 432.329 517.813 427.808 519.563 422.5C521.313 417.192 522.188 411.183 522.188 404.475Z"
              fill="white"
            />
            <path
              d="M477.975 557.475C477.975 566.75 476.4 575.354 473.25 583.287C470.158 591.221 465.754 598.075 460.038 603.85C454.379 609.625 447.554 614.175 439.563 617.5C431.571 620.767 422.704 622.4 412.963 622.4C403.221 622.4 394.354 620.767 386.363 617.5C378.371 614.175 371.517 609.625 365.8 603.85C360.083 598.075 355.65 591.221 352.5 583.287C349.408 575.354 347.863 566.75 347.863 557.475C347.863 548.2 349.408 539.625 352.5 531.75C355.65 523.817 360.083 516.962 365.8 511.187C371.517 505.412 378.371 500.892 386.363 497.625C394.354 494.3 403.221 492.637 412.963 492.637C422.704 492.637 431.571 494.3 439.563 497.625C447.554 500.892 454.379 505.442 460.038 511.275C465.754 517.05 470.158 523.904 473.25 531.837C476.4 539.712 477.975 548.258 477.975 557.475ZM451.113 557.475C451.113 550.825 450.238 544.875 448.488 539.625C446.738 534.317 444.2 529.825 440.875 526.15C437.608 522.417 433.613 519.587 428.888 517.662C424.221 515.679 418.913 514.687 412.963 514.687C407.013 514.687 401.675 515.679 396.95 517.662C392.225 519.587 388.2 522.417 384.875 526.15C381.608 529.825 379.1 534.317 377.35 539.625C375.6 544.875 374.725 550.825 374.725 557.475C374.725 564.183 375.6 570.192 377.35 575.5C379.1 580.75 381.608 585.212 384.875 588.887C388.2 592.562 392.225 595.392 396.95 597.375C401.675 599.3 407.013 600.262 412.963 600.262C418.913 600.262 424.221 599.3 428.888 597.375C433.613 595.392 437.608 592.562 440.875 588.887C444.2 585.212 446.738 580.75 448.488 575.5C450.238 570.192 451.113 564.183 451.113 557.475ZM619.821 557.475C619.821 566.75 618.246 575.354 615.096 583.287C612.004 591.221 607.6 598.075 601.883 603.85C596.225 609.625 589.4 614.175 581.408 617.5C573.417 620.767 564.55 622.4 554.808 622.4C545.067 622.4 536.2 620.767 528.208 617.5C520.217 614.175 513.362 609.625 507.646 603.85C501.929 598.075 497.496 591.221 494.346 583.287C491.254 575.354 489.708 566.75 489.708 557.475C489.708 548.2 491.254 539.625 494.346 531.75C497.496 523.817 501.929 516.962 507.646 511.187C513.362 505.412 520.217 500.892 528.208 497.625C536.2 494.3 545.067 492.637 554.808 492.637C564.55 492.637 573.417 494.3 581.408 497.625C589.4 500.892 596.225 505.442 601.883 511.275C607.6 517.05 612.004 523.904 615.096 531.837C618.246 539.712 619.821 548.258 619.821 557.475ZM592.958 557.475C592.958 550.825 592.083 544.875 590.333 539.625C588.583 534.317 586.046 529.825 582.721 526.15C579.454 522.417 575.458 519.587 570.733 517.662C566.067 515.679 560.758 514.687 554.808 514.687C548.858 514.687 543.521 515.679 538.796 517.662C534.071 519.587 530.046 522.417 526.721 526.15C523.454 529.825 520.946 534.317 519.196 539.625C517.446 544.875 516.571 550.825 516.571 557.475C516.571 564.183 517.446 570.192 519.196 575.5C520.946 580.75 523.454 585.212 526.721 588.887C530.046 592.562 534.071 595.392 538.796 597.375C543.521 599.3 548.858 600.262 554.808 600.262C560.758 600.262 566.067 599.3 570.733 597.375C575.458 595.392 579.454 592.562 582.721 588.887C586.046 585.212 588.583 580.75 590.333 575.5C592.083 570.192 592.958 564.183 592.958 557.475ZM665.241 546.45H670.404C674.721 546.45 677.841 545.108 679.766 542.425L711.879 499.462C713.396 497.421 715.058 496.021 716.866 495.262C718.675 494.446 720.891 494.037 723.516 494.037H746.266L705.841 546.1C703.216 549.483 700.504 551.904 697.704 553.362C699.746 554.179 701.583 555.258 703.216 556.6C704.85 557.883 706.425 559.604 707.941 561.762L749.416 621H726.054C724.537 621 723.225 620.883 722.116 620.65C721.066 620.417 720.133 620.096 719.316 619.687C718.5 619.279 717.8 618.783 717.216 618.2C716.633 617.558 716.079 616.829 715.554 616.012L682.916 570.337C681.808 568.762 680.496 567.654 678.979 567.012C677.462 566.312 675.333 565.962 672.591 565.962H665.241V621H638.991V494.037H665.241V546.45Z"
              fill="white"
            />
          </g>
          <defs>
            <filter
              id="filter0_b_2249_3810"
              x="-20"
              y="-20"
              width="462"
              height="995"
              filterUnits="userSpaceOnUse"
              colorInterpolationFilters="sRGB"
            >
              <feFlood floodOpacity="0" result="BackgroundImageFix" />
              <feGaussianBlur in="BackgroundImageFix" stdDeviation="10" />
              <feComposite
                in2="SourceAlpha"
                operator="in"
                result="effect1_backgroundBlur_2249_3810"
              />
              <feBlend
                mode="normal"
                in="SourceGraphic"
                in2="effect1_backgroundBlur_2249_3810"
                result="shape"
              />
            </filter>
            <clipPath id="clip0_2249_3810">
              <rect
                width="351"
                height="298"
                fill="white"
                transform="translate(422 324)"
              />
            </clipPath>
          </defs>
        </svg>
      </div>
    </div>
  );
}
